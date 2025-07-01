import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/DogDetailScreen.dart'; // Certifique-se de que esta tela existe e está bem projetada

class DogsListScreen extends StatefulWidget {
  const DogsListScreen({super.key});

  @override
  State<DogsListScreen> createState() => _DogsListScreenState();
}

class _DogsListScreenState extends State<DogsListScreen> {
  // Definindo a cor principal do seu app
  final Color primaryAppColor = const Color(0xFF7A4F9F); // O "Roxo Acolhedor"
  final Color lightBackgroundColor =
      const Color(0xFFF3EDF7); // Um lavanda muito suave

  // Remover a lógica de _isHovered e _onHover se não for essencial para o mobile
  // Geralmente, efeitos de hover são mais para web ou desktop.
  // Se você quiser manter um feedback visual de toque, podemos usar InkWell ou GestureDetector.

  final dogsRef = FirebaseFirestore.instance.collection('dogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor, // Fundo suave para a lista
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios,
              color: primaryAppColor), // Ícone de volta no padrão
        ),
        title: Text(
          'Pets para Adoção', // Título mais amigável
          style: TextStyle(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2, // Uma leve sombra para destacar a AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dogsRef.where('available', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Mensagem de erro mais detalhada e amigável
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Ocorreu um erro ao carregar os pets. Verifique sua conexão e tente novamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Indicador de progresso centralizado e com a cor do app
            return Center(
              child: CircularProgressIndicator(color: primaryAppColor),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            // Mensagem para quando não há pets disponíveis, mais convidativa
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_outlined,
                        size: 60, color: primaryAppColor.withOpacity(0.7)),
                    SizedBox(height: 16),
                    Text(
                      'Ops! Parece que não há pets disponíveis para adoção no momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: primaryAppColor),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Volte mais tarde ou considere doar um pet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          // Remover a lógica de _isHovered e _onHover daqui também.
          // O AnimatedScale ainda pode ser usado com onTap se quisermos um efeito de clique.

          return ListView.builder(
            padding: const EdgeInsets.all(12), // Padding geral da lista
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dog = docs[index];
              final data = dog.data()! as Map<String, dynamic>;
              data['id'] = dog.id;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0), // Espaçamento entre os cards
                child: Card(
                  elevation: 6, // Sombra mais proeminente para os cards
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16), // Bordas mais arredondadas
                    side: BorderSide(
                        color: primaryAppColor.withOpacity(0.3),
                        width: 1), // Borda sutil
                  ),
                  color: Colors.white, // Fundo do card branco
                  child: InkWell(
                    // Use InkWell para feedback visual ao tocar
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DogDetailScreen(dog: data),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16.0), // Padding interno do card
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem do Pet
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12), // Bordas da imagem
                            child: (data['imageUrl'] != null &&
                                    data['imageUrl'] != '')
                                ? Image.network(
                                    data['imageUrl'],
                                    width: 90, // Tamanho da imagem
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback para ícone se a imagem falhar
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        color: primaryAppColor.withOpacity(0.1),
                                        child: Icon(Icons.pets,
                                            size: 50,
                                            color: primaryAppColor
                                                .withOpacity(0.6)),
                                      );
                                    },
                                  )
                                : Container(
                                    // Placeholder se não houver URL
                                    width: 90,
                                    height: 90,
                                    color: primaryAppColor.withOpacity(0.1),
                                    child: Icon(Icons.pets,
                                        size: 50,
                                        color:
                                            primaryAppColor.withOpacity(0.6)),
                                  ),
                          ),
                          const SizedBox(
                              width: 16), // Espaçamento entre imagem e texto

                          // Detalhes do Pet
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Nome Desconhecido',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        primaryAppColor, // Nome na cor principal
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Raça: ${data['breed'] ?? 'Não informada'}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Idade: ${data['age'] ?? 'Não informada'} anos',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Localização (Cidade e Estado)
                                if (data['cidade'] != null &&
                                    data['estado'] != null)
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 18,
                                          color:
                                              primaryAppColor.withOpacity(0.8)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        // Para garantir que o texto não exceda
                                        child: Text(
                                          '${data['cidade']}, ${data['estado']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            overflow: TextOverflow
                                                .ellipsis, // Evita estouro de texto
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // Ícone de seta para indicar que é clicável
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios,
                                size: 20,
                                color: primaryAppColor.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
