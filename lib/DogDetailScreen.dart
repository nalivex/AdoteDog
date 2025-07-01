import 'package:flutter/material.dart';
import 'package:flutter_application_2/AdoptFormScreen.dart'; // Certifique-se de ter esta tela
import 'package:flutter_application_2/DogApiService.dart'; // Certifique-se de ter esta classe

class DogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dog;

  const DogDetailScreen({super.key, required this.dog});

  // Definindo a cor principal do seu app
  final Color primaryAppColor = const Color(0xFF7A4F9F); // O "Roxo Acolhedor"
  final Color lightBackgroundColor =
      const Color(0xFFF3EDF7); // Um lavanda muito suave
  final Color secondaryAccentColor =
      const Color(0xFFFFA726); // Laranja para detalhes, se necessário

  // Widget auxiliar para exibir uma linha de informação com ícone
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Novo widget para exibir blocos de informação de forma mais organizada
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 6, // Sombra mais pronunciada
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordas mais arredondadas
        side: BorderSide(
            color: primaryAppColor.withOpacity(0.2), width: 1), // Borda sutil
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20), // Padding interno maior
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryAppColor, // Título da seção na cor principal
              ),
            ),
            const Divider(
                height: 20,
                thickness: 1.5,
                color: Colors.grey), // Divisor sutil
            const SizedBox(height: 10),
            ...children, // Espalha os widgets filhos
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String breed = dog['breed'] ?? 'Não informada';
    final String age =
        (dog['age'] != null) ? '${dog['age']} anos' : 'Não informada';
    final String name = dog['name'] ?? 'Pet Adotável';
    final String description =
        dog['descricao'] ?? 'Este pet está em busca de um lar carinhoso!';

    // Dados de endereço para facilitar o acesso
    final String logradouro = dog['logradouro'] ?? 'Não informado';
    final String bairro = dog['bairro'] ?? 'Não informado';
    final String cidade = dog['cidade'] ?? 'Não informada';
    final String estado = dog['estado'] ?? 'UF';
    final String cep = dog['cep'] ?? 'Não informado';
    final String numero = dog['numero'] ?? 'S/N';

    return Scaffold(
      backgroundColor: lightBackgroundColor, // Fundo suave e acolhedor
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: primaryAppColor),
        ),
        title: Text(
          name, // Título da AppBar é o nome do pet
          style: TextStyle(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          overflow:
              TextOverflow.ellipsis, // Evita estouro de texto em nomes longos
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Padding geral da tela
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção da Imagem do Pet (Centralizada e com fallback)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // Largura responsiva
                height: 280, // Altura fixa para a imagem
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20), // Bordas mais arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: (dog['imageUrl'] != null &&
                          dog['imageUrl'].toString().isNotEmpty)
                      ? Image.network(
                          dog['imageUrl'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryAppColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: primaryAppColor.withOpacity(0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_outlined,
                                      size: 70,
                                      color: primaryAppColor.withOpacity(0.6)),
                                  SizedBox(height: 10),
                                  Text('Imagem não disponível',
                                      style: TextStyle(
                                          color: primaryAppColor
                                              .withOpacity(0.8))),
                                ],
                              ),
                            );
                          },
                        )
                      : Container(
                          color: primaryAppColor.withOpacity(0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets,
                                  size: 80,
                                  color: primaryAppColor.withOpacity(0.6)),
                              SizedBox(height: 10),
                              Text('Nenhuma imagem',
                                  style: TextStyle(
                                      color: primaryAppColor.withOpacity(0.8))),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Nome do Pet (Centralizado e proeminente)
            Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32, // Tamanho maior para o nome
                  fontWeight: FontWeight.w900, // Mais pesado
                  color: primaryAppColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seção "Sobre o Pet"
            _buildSectionCard(
              '❤️ Sobre $name',
              [
                _buildInfoRow(Icons.category, 'Raça', breed,
                    primaryAppColor.withOpacity(0.8)),
                _buildInfoRow(
                    Icons.cake, 'Idade', age, primaryAppColor.withOpacity(0.8)),
                if (description.isNotEmpty)
                  _buildInfoRow(Icons.article, 'História e Temperamento',
                      description, primaryAppColor.withOpacity(0.8)),
              ],
            ),

            // Seção "Endereço do Pet"
            _buildSectionCard(
              '📍 Onde encontrar $name',
              [
                _buildInfoRow(Icons.map, 'Logradouro', '$logradouro, $numero',
                    primaryAppColor.withOpacity(0.8)),
                _buildInfoRow(Icons.landscape, 'Bairro', bairro,
                    primaryAppColor.withOpacity(0.8)),
                _buildInfoRow(Icons.location_city, 'Cidade/Estado',
                    '$cidade - $estado', primaryAppColor.withOpacity(0.8)),
                _buildInfoRow(Icons.numbers, 'CEP', cep,
                    primaryAppColor.withOpacity(0.8)),
              ],
            ),

            // Seção "Sobre a Raça" (Informações da API externa)
            _buildSectionCard(
              '🐾 Detalhes da Raça ($breed)',
              [
                FutureBuilder<Map<String, dynamic>?>(
                  future: fetchBreedInfo(
                      breed), // Assumindo que esta função existe e funciona
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: primaryAppColor));
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Erro ao carregar detalhes da raça: ${snapshot.error}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      );
                    }
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Informações adicionais sobre a raça não encontradas.',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic),
                        ),
                      );
                    }

                    final breedInfo = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (breedInfo['origin'] != null &&
                            breedInfo['origin'].isNotEmpty)
                          _buildInfoRow(
                              Icons.public,
                              'Origem',
                              breedInfo['origin'],
                              primaryAppColor.withOpacity(0.8)),
                        if (breedInfo['life_span'] != null &&
                            breedInfo['life_span'].isNotEmpty)
                          _buildInfoRow(
                              Icons.watch_later_outlined,
                              'Expectativa de Vida',
                              '${breedInfo['life_span']} anos',
                              primaryAppColor.withOpacity(0.8)),
                        if (breedInfo['temperament'] != null &&
                            breedInfo['temperament'].isNotEmpty)
                          _buildInfoRow(
                              Icons.psychology_outlined,
                              'Temperamento',
                              breedInfo['temperament'],
                              primaryAppColor.withOpacity(0.8)),
                        if (breedInfo['bred_for'] != null &&
                            breedInfo['bred_for'].isNotEmpty)
                          _buildInfoRow(
                              Icons.engineering_outlined,
                              'Criado Para',
                              breedInfo['bred_for'],
                              primaryAppColor.withOpacity(0.8)),
                        if (breedInfo['breed_group'] != null &&
                            breedInfo['breed_group'].isNotEmpty)
                          _buildInfoRow(
                              Icons.group_work_outlined,
                              'Grupo da Raça',
                              breedInfo['breed_group'],
                              primaryAppColor.withOpacity(0.8)),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botão "Quero Adotar!"
            Center(
              child: SizedBox(
                width: double.infinity, // Ocupa a largura total
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
                      : null, // Desabilita o botão se o pet não estiver disponível
                  icon: const Icon(Icons.favorite_border,
                      size: 28), // Ícone de coração
                  label: Text(
                    dog['available'] == true
                        ? 'Quero Adotar!'
                        : 'Pet Adotado :(',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dog['available'] == true
                        ? primaryAppColor
                        : Colors.grey, // Cor do botão
                    foregroundColor: Colors.white, // Cor do texto e ícone
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8, // Sombra para destaque
                    shadowColor: primaryAppColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Espaço inferior
          ],
        ),
      ),
    );
  }
}
