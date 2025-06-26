import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptFormScreen extends StatefulWidget {
  final String dogId;

  const AdoptFormScreen({super.key, required this.dogId});

  @override
  State<AdoptFormScreen> createState() => _AdoptFormScreenState();
}

class _AdoptFormScreenState extends State<AdoptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _loading = false;

  Future<void> _adotarCachorro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Salvar dados da adoção (opcional)
      await FirebaseFirestore.instance.collection('adocoes').add({
        'nome': _nomeController.text,
        'telefone': _telefoneController.text,
        'dogId': widget.dogId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Atualizar campo available do cachorro
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(widget.dogId)
          .update({
        'available': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adoção realizada com sucesso!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adotar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário de Adoção')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Seu nome'),
                validator: (value) => value!.isEmpty ? 'Preencha o nome' : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (value) =>
                    value!.isEmpty ? 'Preencha o telefone' : null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _adotarCachorro,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Confirmar Adoção'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
