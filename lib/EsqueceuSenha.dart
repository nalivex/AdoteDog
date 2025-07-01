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

  // Definindo a cor principal do seu app para consistência
  final Color primaryAppColor = const Color(0xFF7A4F9F); // O "Roxo Acolhedor"

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _enviarEmail() async {
    final email = _emailController.text.trim();

    final resultado = await _authservice.trocarSenha(email);

    if (resultado == null) {
      // Mensagem genérica para segurança (evitar informar se o e-mail existe)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Se o e-mail estiver registrado, você receberá um link de redefinição de senha.',
          ),
          backgroundColor:
              Colors.green, // Cor para feedback de sucesso/informação
        ),
      );
      // Opcional: Voltar para a tela de login após enviar o e-mail
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(resultado), // Exibe o erro específico retornado pelo serviço
          backgroundColor: Colors.red, // Cor para feedback de erro
        ),
      );
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
            icon: Icon(Icons.arrow_back_ios,
                color: primaryAppColor), // Ícone de volta moderno e com cor
          ),
          title: Text(
            'Redefinir Senha',
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
          // Centraliza o conteúdo principal na tela
          child: SingleChildScrollView(
            // Permite rolagem se o conteúdo exceder a tela
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone ilustrativo
                Icon(
                  Icons.lock_reset, // Ícone que remete a redefinição de senha
                  size: 100,
                  color: primaryAppColor.withOpacity(0.7), // Cor suave da logo
                ),
                const SizedBox(height: 30),

                // Mensagem explicativa
                Text(
                  'Esqueceu sua senha? Sem problemas!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryAppColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Informe seu e-mail abaixo e enviaremos um link para você redefinir sua senha.',
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
                          hintText: 'Seu e-mail cadastrado',
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

                      const SizedBox(height: 30),

                      // Botão de Enviar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _enviarEmail();
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
                            'Redefinir Senha',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
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
