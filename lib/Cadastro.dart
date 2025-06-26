import 'package:flutter/material.dart';
import 'package:flutter_application_2/authService.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  final AuthService _authservice = AuthService();

  @override
  void initState() {
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    final resultado = await _authservice.cadastrar(email, senha);

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado! Verfique o Email')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resultado)));
    }
  }

  GlobalKey<FormState> formKey = GlobalKey();

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
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(),
                      ),

                      validator: (value) {
                        if (value == '') return 'Preencha o campo email!';
                        if (!value!.contains('@'))
                          return 'Forneça um email válido!';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _senhaController,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == '') return 'Preencha o campo senha!';
                        if (value!.length < 6)
                          return 'A senha deve ter no mínimo 6 caracteres!';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _cadastrar();
                        }
                      },
                      child: Text('Cadastrar'),
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
