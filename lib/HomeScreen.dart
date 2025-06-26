import 'package:flutter/material.dart';
import 'package:flutter_application_2/AddDogScreen.dart';
import 'package:flutter_application_2/DogListScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌄 Imagem de fundo
          Image.network(
            'https://i.pinimg.com/474x/02/ec/ec/02ecec147ec87a66e44cca4d08ffb038.jpg',
            fit: BoxFit.cover,
          ),

          // 🧼 Camada escura por cima da imagem
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 📦 Conteúdo da tela
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100), // Espaço no topo
                Text(
                  'Bem-vindo ao App de Adoção de Animais',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Animal para Adoção'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddDogScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Cor de fundo do botão
                    foregroundColor: Colors.white, // Cor do texto do botão
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.pets),
                  label: const Text('Ver Animais Disponíveis'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DogsListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Cor de fundo do botão
                    foregroundColor: Colors.white, // Cor do texto do botão
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
