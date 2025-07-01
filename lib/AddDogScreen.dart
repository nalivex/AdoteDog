import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AddDogScreen extends StatefulWidget {
  const AddDogScreen({super.key});

  @override
  State<AddDogScreen> createState() => _AddDogScreenState();
}

class _AddDogScreenState extends State<AddDogScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers dos dados do cachorro
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descricaoController = TextEditingController();

  // Controllers de endereço
  final cepController = TextEditingController();
  final logradouroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final numeroController = TextEditingController();

  List<String> _racas = [];
  String? _racaSelecionada;

  // Definindo a cor principal do seu app
  final Color primaryAppColor = const Color(0xFF7A4F9F);
  final Color lightBackgroundColor = const Color(0xFFF3EDF7);

  @override
  void initState() {
    super.initState();
    _carregarRacas();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    imageUrlController.dispose();
    descricaoController.dispose();
    cepController.dispose();
    logradouroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  Future<void> _carregarRacas() async {
    setState(() {
      _racas = ['Carregando raças...']; // Feedback de carregamento
      _racaSelecionada = null; // Limpa a seleção enquanto carrega
    });
    try {
      final url = Uri.parse('https://api.thedogapi.com/v1/breeds');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final racas =
            data.map<String>((item) => item['name'] as String).toList();
        racas.sort(); // Ordenar as raças alfabeticamente

        setState(() {
          _racas = racas;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Erro ao carregar raças. Tente novamente mais tarde.'),
              backgroundColor: Colors.red),
        );
        setState(() {
          _racas = ['Erro ao carregar']; // Indica um erro no carregamento
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro de conexão ao carregar raças: $e'),
            backgroundColor: Colors.red),
      );
      setState(() {
        _racas = ['Erro de rede']; // Indica um erro de rede
      });
    }
  }

  Future<void> _buscarCep(String cep) async {
    setState(() {
      logradouroController.text = '';
      bairroController.text = '';
      cidadeController.text = '';
      estadoController.text = '';
    });

    if (cep.length != 8) return; // Só busca se o CEP tiver 8 dígitos

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('erro')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('CEP não encontrado ou inválido.'),
                backgroundColor: Colors.orange),
          );
          return;
        }

        setState(() {
          logradouroController.text = data['logradouro'] ?? '';
          bairroController.text = data['bairro'] ?? '';
          cidadeController.text = data['localidade'] ?? '';
          estadoController.text = data['uf'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao buscar CEP. Verifique sua conexão.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro de conexão ao buscar CEP: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _salvarDog() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('dogs').add({
          'name': nameController.text.trim(),
          'age': int.tryParse(ageController.text) ?? 0,
          'breed': _racaSelecionada,
          'imageUrl': imageUrlController.text.trim(),
          'descricao': descricaoController.text.trim(),
          'available': true,
          'cep': cepController.text.trim(),
          'logradouro': logradouroController.text.trim(),
          'bairro': bairroController.text.trim(),
          'cidade': cidadeController.text.trim(),
          'estado': estadoController.text.trim(),
          'numero': numeroController.text.trim(),
          'timestamp':
              FieldValue.serverTimestamp(), // Adiciona um timestamp de criação
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Animal adicionado com sucesso para adoção!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao salvar animal: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _mostrarDialogNovaRaca() async {
    String novaRaca = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Nova Raça',
              style: TextStyle(color: primaryAppColor)),
          content: TextField(
            controller:
                TextEditingController(), // Novo controller para o dialog
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nome da Raça',
              hintText: 'Ex: Vira-lata, Poodle',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryAppColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryAppColor, width: 2),
              ),
              prefixIcon:
                  Icon(Icons.pets, color: primaryAppColor.withOpacity(0.7)),
            ),
            onChanged: (value) => novaRaca = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: primaryAppColor.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, novaRaca),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool readOnly = false,
    int? maxLength,
    Function(String)? onChanged,
    int maxLines = 1, // Adicionado para descrição
    String? Function(String?)?
        validator, // Adicionado para validação personalizada
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0), // Espaçamento entre os campos
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryAppColor.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: primaryAppColor.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryAppColor.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryAppColor, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white, // Fundo branco para os campos
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator ??
            (value) => value!.isEmpty
                ? 'Por favor, informe ${label.toLowerCase()}'
                : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _racaSelecionada,
        isExpanded: true, // Faz o dropdown ocupar a largura total disponível
        items: [
          // Mapeia as raças. Usamos `Text` com `overflow` para evitar estouro
          ..._racas.map((raca) => DropdownMenuItem(
                value: raca,
                child: Text(
                  raca,
                  overflow: TextOverflow
                      .ellipsis, // Corta o texto com "..." se for muito longo
                ),
              )),
          if (!_racas.contains('Carregando raças...') &&
              !_racas.contains('Erro ao carregar') &&
              !_racas.contains('Erro de rede'))
            const DropdownMenuItem(
              value: 'outra',
              child: Text('Outra raça...',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ),
        ],
        onChanged: (value) async {
          if (value == 'outra') {
            final novaRaca = await _mostrarDialogNovaRaca();
            if (novaRaca != null && novaRaca.isNotEmpty) {
              setState(() {
                _racas.add(novaRaca);
                _racas.sort();
                _racaSelecionada = novaRaca;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Raça não adicionada.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            setState(() {
              _racaSelecionada = value;
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'Raça do Pet',
          labelStyle: TextStyle(color: primaryAppColor.withOpacity(0.8)),
          prefixIcon:
              Icon(Icons.category, color: primaryAppColor.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryAppColor.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryAppColor, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        // A validação agora trata corretamente o estado inicial do dropdown
        validator: (value) {
          if (_racas.contains('Carregando raças...') ||
              _racas.contains('Erro ao carregar') ||
              _racas.contains('Erro de rede')) {
            return 'Aguarde o carregamento das raças ou resolva o erro.';
          }
          if (value == null || value.isEmpty || value == 'outra') {
            return 'Por favor, selecione ou adicione a raça do pet';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios,
              color: primaryAppColor), // Ícone de volta
        ),
        title: Text(
          'Doar um Pet',
          style: TextStyle(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2, // Uma leve sombra para destacar
      ),
      body: _racas.isEmpty ||
              _racas.contains('Carregando raças...') ||
              _racas.contains('Erro ao carregar') ||
              _racas.contains('Erro de rede')
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_racas.contains('Carregando raças...'))
                    CircularProgressIndicator(color: primaryAppColor),
                  if (_racas.contains('Carregando raças...'))
                    const SizedBox(height: 16),
                  if (_racas.contains('Carregando raças...'))
                    Text('Carregando raças de pets...',
                        style: TextStyle(color: primaryAppColor)),
                  if (_racas.contains('Erro ao carregar') ||
                      _racas.contains('Erro de rede'))
                    Icon(Icons.error_outline, size: 50, color: Colors.red),
                  if (_racas.contains('Erro ao carregar') ||
                      _racas.contains('Erro de rede'))
                    const SizedBox(height: 16),
                  if (_racas.contains('Erro ao carregar'))
                    Text(
                      'Não foi possível carregar as raças. Tente novamente.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  if (_racas.contains('Erro de rede'))
                    Text(
                      'Problema de conexão. Verifique sua internet e tente novamente.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  if (_racas.contains('Erro ao carregar') ||
                      _racas.contains('Erro de rede'))
                    const SizedBox(height: 20),
                  if (_racas.contains('Erro ao carregar') ||
                      _racas.contains('Erro de rede'))
                    ElevatedButton(
                      onPressed: _carregarRacas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAppColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tentar Novamente'),
                    ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24), // Padding uniforme
                children: [
                  Text(
                    '🐾 Detalhes do Pet', // Emoji e texto mais acolhedor
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryAppColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                      nameController, 'Nome do Pet', Icons.person_outline),
                  _buildTextField(
                    ageController,
                    'Idade do Pet (em anos)',
                    Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe a idade do pet.';
                      }
                      if (int.tryParse(value) == null) {
                        return 'A idade deve ser um número inteiro.';
                      }
                      return null;
                    },
                  ),
                  _buildDropdownField(), // O dropdown agora deve estar corrigido
                  _buildTextField(imageUrlController, 'URL da Imagem do Pet',
                      Icons.image_outlined, keyboardType: TextInputType.url,
                      validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a URL da imagem do pet.';
                    }
                    // Regex simples para URL. Pode ser mais robusto.
                    if (!Uri.tryParse(value)!.hasAbsolutePath) {
                      return 'Insira uma URL válida.';
                    }
                    return null;
                  }),
                  _buildTextField(descricaoController,
                      'História e Temperamento do Pet', Icons.article_outlined,
                      maxLines: 4, // Permite múltiplas linhas para descrição
                      validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, forneça uma descrição do pet.';
                    }
                    return null;
                  }),
                  const SizedBox(height: 30),
                  Divider(
                      color: primaryAppColor
                          .withOpacity(0.5)), // Divisor na cor principal
                  const SizedBox(height: 30),
                  Text(
                    '🏡 Onde o Pet está?', // Título da seção de endereço
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryAppColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    cepController,
                    'CEP',
                    Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    onChanged: (value) {
                      if (value.length == 8) {
                        _buscarCep(value);
                        FocusScope.of(context)
                            .unfocus(); // Fecha o teclado após digitar o CEP
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe o CEP.';
                      }
                      if (value.length != 8) {
                        return 'O CEP deve ter 8 dígitos.';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                      logradouroController, 'Logradouro', Icons.map_outlined,
                      readOnly: true),
                  _buildTextField(
                      bairroController, 'Bairro', Icons.landscape_outlined,
                      readOnly: true),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(cidadeController, 'Cidade',
                            Icons.location_city_outlined,
                            readOnly: true),
                      ),
                      const SizedBox(
                          width: 16), // Espaçamento entre cidade e estado
                      Expanded(
                        child: _buildTextField(
                            estadoController, 'UF', Icons.flag_outlined,
                            readOnly: true,
                            maxLength: 2), // UF tem 2 caracteres
                      ),
                    ],
                  ),
                  _buildTextField(
                    numeroController,
                    'Número',
                    Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe o número.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity, // Ocupa largura total
                    child: ElevatedButton.icon(
                      onPressed: _salvarDog,
                      icon: const Icon(Icons.check_circle_outline,
                          size: 28), // Ícone de confirmação
                      label: const Text(
                        'Confirmar Doação', // Texto mais impactante
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAppColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Mais arredondado
                        ),
                        elevation: 8, // Sombra mais proeminente
                        shadowColor: primaryAppColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Espaço para rolagem final
                ],
              ),
            ),
    );
  }
}
