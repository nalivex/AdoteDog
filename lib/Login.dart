import 'package:flutter_application_2/EsqueceuSenha.dart';
import 'package:flutter_application_2/Cadastro.dart';
import 'package:flutter_application_2/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/authService.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  final AuthService _authservice = AuthService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _senhaController.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    final resultado = await _authservice.login(email, senha);

    if (resultado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login realizado com sucesso!!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                      child: Text('Entrar'),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Esqueceusenha(),
                          ),
                        );
                      },
                      child: Text('Esqueceu sua senha?'),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Cadastro()),
                        );
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
