import 'package:flutter/material.dart';
import 'package:flutter_application_2/authService.dart';

class Esqueceusenha extends StatefulWidget {
  const Esqueceusenha({super.key});

  @override
  State<Esqueceusenha> createState() => _EsqueceusenhaState();
}

class _EsqueceusenhaState extends State<Esqueceusenha> {
  late TextEditingController _emailController;

  final AuthService _authservice = AuthService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  GlobalKey<FormState> formKey = GlobalKey();

  Future<void> _enviarEmail() async {
    final email = _emailController.text.trim();

    final resultado = await _authservice.trocarSenha(email);

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se o email tiver correto, você receberá um link de redefinição',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('resultado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Seu Email',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == '') {
                          return 'Preencha o campo!';
                        } else if (value!.contains('@') == false) {
                          return 'Forneça um email válido!';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _enviarEmail();
                        }
                      },
                      child: Text('Enviar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
