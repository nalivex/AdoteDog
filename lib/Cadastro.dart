import 'package:flutter/material.dart';
import 'package:flutter_application_2/authService.dart';
import 'package:flutter_application_2/HomeScreen.dart'; // Importar HomeScreen para redirecionar após o cadastro

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  late TextEditingController
      _confirmarSenhaController; // Novo controlador para confirmar senha

  final AuthService _authservice = AuthService();

  // Definindo a cor principal do seu app
  final Color primaryAppColor =
      const Color(0xFF7A4F9F); // O "Roxo Acolhedor" que criamos

  @override
  void initState() {
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
    _confirmarSenhaController =
        TextEditingController(); // Inicializa o novo controlador
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose(); // Descarte o novo controlador
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    // Adiciona uma verificação para garantir que as senhas são iguais antes de tentar cadastrar
    if (senha != _confirmarSenhaController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Impede o cadastro se as senhas forem diferentes
    }

    final resultado = await _authservice.cadastrar(email, senha);

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cadastro realizado com sucesso! Verifique seu e-mail para confirmação.'),
          backgroundColor: Colors.green, // Feedback visual de sucesso
        ),
      );
      // Opcional: Redirecionar para a tela inicial ou tela de login após o cadastro
      // Se você quer que o usuário volte para o login, use Navigator.pop(context);
      // Se quer que ele vá para a home diretamente, talvez com login automático, use:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado),
          backgroundColor: Colors.red, // Feedback visual de erro
        ),
      );
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios,
                color: primaryAppColor), // Ícone de volta moderno e com cor
          ),
          title: Text(
            'Criar Nova Conta',
            style: TextStyle(
              color: primaryAppColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0, // Remove a sombra da AppBar para um visual mais limpo
        ),
        body: Center(
          // Centraliza o conteúdo principal
          child: SingleChildScrollView(
            // Permite rolagem
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mensagem de boas-vindas para o cadastro
                Text(
                  'Junte-se à nossa comunidade!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryAppColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Crie sua conta para encontrar o pet perfeito.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Seu e-mail',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: primaryAppColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryAppColor, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, preencha o campo de e-mail!';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Forneça um e-mail válido!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Crie sua senha',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: primaryAppColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryAppColor, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, crie uma senha!';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter no mínimo 6 caracteres!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller:
                            _confirmarSenhaController, // Campo de confirmação de senha
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirme sua senha',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: Icon(Icons.lock_reset_outlined,
                              color: primaryAppColor), // Ícone diferente
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryAppColor, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, confirme sua senha!';
                          }
                          if (value != _senhaController.text.trim()) {
                            return 'As senhas não coincidem!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Botão de Cadastrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _cadastrar();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAppColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: primaryAppColor.withOpacity(0.4),
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Voltar para o Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem uma conta?',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Volta para a tela anterior (Login)
                            },
                            child: Text(
                              'Faça login aqui',
                              style: TextStyle(
                                color: primaryAppColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
