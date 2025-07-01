import 'package:flutter/material.dart';
import 'package:flutter_application_2/AddDogScreen.dart';
import 'package:flutter_application_2/DogListScreen.dart';
import 'package:flutter_application_2/Login.dart'; // Importar a tela de Login para o botão de sair

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Definindo a cor principal do seu app: o "Roxo Acolhedor"
  final Color primaryAppColor = const Color(0xFF7A4F9F);
  // Uma cor secundária mais clara para detalhes
  final Color lightBackgroundColor =
      const Color(0xFFF3EDF7); // Um lavanda muito suave

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor, // Fundo suave e acolhedor
      appBar: AppBar(
        title: Text(
          'AdotePet',
          style: TextStyle(
            color: primaryAppColor, // Título na cor principal
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // AppBar branca
        elevation: 2, // Uma leve sombra para destacar a AppBar
        actions: [
          // Botão de Sair/Logout
          IconButton(
            icon: Icon(Icons.logout,
                color: primaryAppColor), // Ícone na cor principal
            tooltip: 'Sair da conta', // Descrição ao segurar o botão
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Você saiu da sua conta.')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          // Permite rolagem
          padding: const EdgeInsets.all(24.0), // Padding geral
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centraliza horizontalmente
            children: [
              // Logo do AdotePet
              Image.asset(
                'assets/images/logo.png',
                height: 150, // Tamanho da logo um pouco maior
              ),
              const SizedBox(height: 30),

              // Título e mensagem principal
              Text(
                'Um lar é tudo que eles precisam.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryAppColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Conectamos corações em busca de um novo melhor amigo.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87.withOpacity(0.7), // Texto mais suave
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Botão "Doar um Pet"
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.85, // Mais largo (85%)
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.pets, size: 26),
                  label: const Text(
                    'Quero Doar um Pet',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddDogScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAppColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20), // Mais padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Mais arredondado
                    ),
                    elevation: 7, // Sombra sutil
                    shadowColor: primaryAppColor.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 25), // Espaçamento entre botões

              // Botão "Buscar um Pet"
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: OutlinedButton.icon(
                  // Usando OutlinedButton para um estilo secundário
                  icon: Icon(Icons.search, size: 26, color: primaryAppColor),
                  label: Text(
                    'Quero Adotar um Pet', // Texto mais direto
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: primaryAppColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DogsListScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: primaryAppColor,
                        width: 2), // Borda na cor principal
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0, // Sem sombra para OutlinedButton
                    backgroundColor: Colors.white, // Fundo branco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
