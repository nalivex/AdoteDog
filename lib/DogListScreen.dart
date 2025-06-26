import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/DogDetailScreen.dart';

class DogsListScreen extends StatefulWidget {
  const DogsListScreen({super.key});

  @override
  State<DogsListScreen> createState() => _DogsListScreenState();
}

class _DogsListScreenState extends State<DogsListScreen> {
  final List<bool> _isHovered = [];
  final dogsRef = FirebaseFirestore.instance.collection('dogs');

  void _onHover(int index, bool isHovered) {
    setState(() {
      _isHovered[index] = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais Disponíveis'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dogsRef.where('available', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum animal disponível.'));
          }

          // Ajusta a lista de hover conforme necessário
          if (_isHovered.length != docs.length) {
            _isHovered.clear();
            _isHovered.addAll(List.generate(docs.length, (index) => false));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dog = docs[index];
              final data = dog.data()! as Map<String, dynamic>;
              data['id'] = dog.id;

              return MouseRegion(
                onEnter: (_) => _onHover(index, true),
                onExit: (_) => _onHover(index, false),
                child: AnimatedScale(
                  scale: _isHovered[index] ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading:
                          (data['imageUrl'] != null && data['imageUrl'] != '')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    data['imageUrl'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.pets, size: 60);
                                    },
                                  ),
                                )
                              : const Icon(Icons.pets, size: 60),
                      title: Text(
                        data['name'] ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Raça: ${data['breed'] ?? '-'}\nIdade: ${data['age'] ?? '-'}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DogDetailScreen(dog: data),
                          ),
                        );
                      },
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
