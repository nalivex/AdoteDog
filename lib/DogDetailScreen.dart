import 'package:flutter/material.dart';
import 'package:flutter_application_2/AdoptFormScreen.dart';
import 'package:flutter_application_2/DogApiService.dart';

class DogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dog;

  const DogDetailScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    final breed = dog['breed'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(dog['name'] ?? 'Detalhes do Animal'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do cachorro
            dog['imageUrl'] != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      dog['imageUrl'],
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.pets, size: 150),
            const SizedBox(height: 20),
            // Nome do cachorro
            Text(
              dog['name'] ?? 'Sem nome',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Informações do cachorro
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Raça: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(breed, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Idade: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${dog['age']} anos',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (dog['descricao'] != null &&
                        dog['descricao'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Descrição: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Expanded(
                            child: Text(
                              dog['descricao'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('📍 Endereço',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Rua: ${dog['logradouro'] ?? '-'}'),
            Text('Bairro: ${dog['bairro'] ?? '-'}'),
            Text('Cidade: ${dog['cidade'] ?? '-'} - ${dog['estado'] ?? '-'}'),
            Text('CEP: ${dog['cep'] ?? '-'}'),
            const SizedBox(height: 20),
            const Divider(),
            const Text('🔎 Sobre a Raça',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            FutureBuilder<Map<String, dynamic>?>(
              future: fetchBreedInfo(breed),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Informações da raça não encontradas.');
                }

                final breedInfo = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (breedInfo['origin'] != null)
                      _buildInfoCard('🌍 Origem', breedInfo['origin']),
                    if (breedInfo['life_span'] != null)
                      _buildInfoCard(
                          '📅 Expectativa de vida', breedInfo['life_span']),
                    if (breedInfo['temperament'] != null)
                      _buildInfoCard(
                          '💬 Temperamento', breedInfo['temperament']),
                    if (breedInfo['bred_for'] != null)
                      _buildInfoCard('🐾 Criado para', breedInfo['bred_for']),
                    if (breedInfo['breed_group'] != null)
                      _buildInfoCard('📦 Grupo', breedInfo['breed_group']),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: dog['available'] == true
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdoptFormScreen(dogId: dog['id']),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Adotar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
