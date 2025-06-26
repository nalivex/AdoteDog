import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AddDogScreen extends StatefulWidget {
  const AddDogScreen({super.key});

  @override
  State<AddDogScreen> createState() => _AddDogScreenState();
}

class _AddDogScreenState extends State<AddDogScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers dos dados do cachorro
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descricaoController = TextEditingController();

  // Controllers de endereço
  final cepController = TextEditingController();
  final logradouroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final numeroController = TextEditingController();

  List<String> _racas = [];
  String? _racaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarRacas();
  }

  Future<void> _carregarRacas() async {
    final url = Uri.parse('https://api.thedogapi.com/v1/breeds');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final racas = data.map<String>((item) => item['name'] as String).toList();
      racas.sort();

      setState(() {
        _racas = racas;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar raças')),
      );
    }
  }

  Future<void> _buscarCep(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('erro')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado.')),
        );
        return;
      }

      setState(() {
        logradouroController.text = data['logradouro'] ?? '';
        bairroController.text = data['bairro'] ?? '';
        cidadeController.text = data['localidade'] ?? '';
        estadoController.text = data['uf'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar CEP.')),
      );
    }
  }

  Future<void> _salvarDog() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('dogs').add({
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text) ?? 0,
        'breed': _racaSelecionada,
        'imageUrl': imageUrlController.text.trim(),
        'descricao': descricaoController.text.trim(),
        'available': true,
        'cep': cepController.text.trim(),
        'logradouro': logradouroController.text.trim(),
        'bairro': bairroController.text.trim(),
        'cidade': cidadeController.text.trim(),
        'estado': estadoController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal adicionado com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  Future<String?> _mostrarDialogNovaRaca() async {
    String novaRaca = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar nova raça'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Digite a nova raça',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => novaRaca = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, novaRaca),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool readOnly = false,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength,
      validator: (value) => value!.isEmpty ? 'Informe $label' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _racaSelecionada,
      items: [
        ..._racas.map((raca) => DropdownMenuItem(
              value: raca,
              child: Text(raca),
            )),
        const DropdownMenuItem(
          value: 'outra',
          child: Text('Outra raça...'),
        ),
      ],
      onChanged: (value) async {
        if (value == 'outra') {
          final novaRaca = await _mostrarDialogNovaRaca();
          if (novaRaca != null && novaRaca.isNotEmpty) {
            setState(() {
              _racas.add(novaRaca);
              _racas.sort();
              _racaSelecionada = novaRaca;
            });
          }
        } else {
          setState(() {
            _racaSelecionada = value;
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Raça do cachorro',
        border: OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty || value == 'outra')
          ? 'Selecione ou adicione uma raça'
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Animal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _racas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      '🐶 Dados do Cachorro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(nameController, 'Nome', Icons.pets),
                    _buildTextField(
                        ageController, 'Idade', Icons.calendar_today,
                        keyboardType: TextInputType.number),
                    _buildDropdownField(),
                    _buildTextField(
                        imageUrlController, 'URL da Imagem', Icons.image),
                    _buildTextField(
                        descricaoController, 'Descrição', Icons.description),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      '📍 Localização do Cachorro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(cepController, 'CEP', Icons.location_on,
                        keyboardType: TextInputType.number,
                        maxLength: 8, onChanged: (value) {
                      if (value.length == 8) {
                        _buscarCep(value);
                      }
                    }),
                    _buildTextField(
                        logradouroController, 'Logradouro', Icons.home,
                        readOnly: true),
                    _buildTextField(
                        bairroController, 'Bairro', Icons.location_city,
                        readOnly: true),
                    _buildTextField(
                        cidadeController, 'Cidade', Icons.location_city,
                        readOnly: true),
                    _buildTextField(estadoController, 'Estado', Icons.flag,
                        readOnly: true),
                    _buildTextField(numeroController, 'Número', Icons.numbers,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _salvarDog,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
