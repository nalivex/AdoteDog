import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdoptFormScreen extends StatefulWidget {
  final String dogId;

  const AdoptFormScreen({super.key, required this.dogId});

  @override
  State<AdoptFormScreen> createState() => _AdoptFormScreenState();
}

class _AdoptFormScreenState extends State<AdoptFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para as informações do adotante
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  // Controllers para endereço
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _numeroController = TextEditingController();

  // Variáveis para as perguntas de adoção
  String? _tipoResidencia;
  bool _possuiTelaProtecao = false;
  bool _todosDeAcordo = false;
  String? _outrosPets;
  String? _experienciaAnterior;
  int? _horasSozinho;
  String? _cuidadorViagens;
  bool _conscienteCustos = false;
  bool _conscienteRotina = false;

  bool _loading = false; // Estado de carregamento do formulário

  // Definindo a cor principal do seu app
  final Color primaryAppColor = const Color(0xFF7A4F9F); // O "Roxo Acolhedor"
  final Color lightBackgroundColor =
      const Color(0xFFF3EDF7); // Um lavanda muito suave

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  // Função para buscar CEP
  Future<void> _buscarCep(String cep) async {
    // Limpa os campos de endereço antes de buscar
    setState(() {
      _logradouroController.text = '';
      _bairroController.text = '';
      _cidadeController.text = '';
      _estadoController.text = '';
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
          _logradouroController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['localidade'] ?? '';
          _estadoController.text = data['uf'] ?? '';
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

  Future<void> _adotarCachorro() async {
    if (!_formKey.currentState!.validate()) {
      // Role para o primeiro erro de validação, se houver
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        alignment: 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Validações adicionais para os campos de seleção
    if (_tipoResidencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione o tipo de residência.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_outrosPets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, informe se possui outros pets.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_experienciaAnterior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, informe sua experiência anterior com pets.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_horasSozinho == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, informe quantas horas o pet ficaria sozinho.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_cuidadorViagens == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, informe quem cuidaria do pet em viagens.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Salvar dados da adoção
      await FirebaseFirestore.instance.collection('adoptions').add({
        'dogId': widget.dogId,
        'adopterName': _nomeController.text.trim(),
        'adopterEmail': _emailController.text.trim(),
        'adopterPhone': _telefoneController.text.trim(),
        'adopterAddress': {
          'cep': _cepController.text.trim(),
          'logradouro': _logradouroController.text.trim(),
          'numero': _numeroController.text.trim(),
          'bairro': _bairroController.text.trim(),
          'cidade': _cidadeController.text.trim(),
          'estado': _estadoController.text.trim(),
        },
        'residenceType': _tipoResidencia,
        'hasScreenProtection': _possuiTelaProtecao,
        'allResidentsAgree': _todosDeAcordo,
        'otherPets': _outrosPets,
        'previousPetExperience': _experienciaAnterior,
        'hoursAlonePerDay': _horasSozinho,
        'travelCaregiver': _cuidadorViagens,
        'awareOfCosts': _conscienteCustos,
        'awareOfRoutine': _conscienteRotina,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pendente', // Status inicial da adoção
      });

      // Atualizar campo 'available' do cachorro
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(widget.dogId)
          .update({
        'available': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sua solicitação de adoção foi enviada com sucesso! Entraremos em contato em breve.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.popUntil(
            context,
            (route) => route
                .isFirst); // Volta para a primeira tela (geralmente lista de cães)
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar solicitação de adoção: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget auxiliar para construir campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool readOnly = false,
    int? maxLength,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLength: maxLength,
        validator: validator ??
            (value) => value!.isEmpty
                ? 'Por favor, informe ${label.toLowerCase()}'
                : null,
        onChanged: onChanged,
      ),
    );
  }

  // Widget auxiliar para construir DropdownFields com validação
  Widget _buildDropdownField<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged, {
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryAppColor.withOpacity(0.8)),
          prefixIcon: Icon(Icons.arrow_drop_down_circle,
              color: primaryAppColor.withOpacity(0.7)),
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator ??
            (val) => val == null ? 'Por favor, selecione uma opção.' : null,
      ),
    );
  }

  // Widget auxiliar para CheckboxListTile
  Widget _buildCheckboxListTile(
    String title,
    String subtitle,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: CheckboxListTile(
        title: Text(title,
            style:
                TextStyle(color: primaryAppColor, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
        value: value,
        onChanged: onChanged,
        activeColor: primaryAppColor,
        checkColor: Colors.white,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
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
          icon: Icon(Icons.arrow_back_ios, color: primaryAppColor),
        ),
        title: Text(
          'Formulário de Adoção',
          style: TextStyle(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryAppColor),
                  const SizedBox(height: 16),
                  Text('Enviando sua solicitação...',
                      style: TextStyle(color: primaryAppColor)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seus Dados Pessoais',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryAppColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nomeController,
                      'Seu Nome Completo',
                      Icons.person_outline,
                      validator: (value) => value!.isEmpty
                          ? 'Por favor, informe seu nome completo.'
                          : null,
                    ),
                    _buildTextField(
                      _emailController,
                      'Seu Email',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Por favor, informe seu email.';
                        if (!value.contains('@') || !value.contains('.'))
                          return 'Email inválido.';
                        return null;
                      },
                    ),
                    _buildTextField(
                      _telefoneController,
                      'Telefone (com DDD)',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Por favor, informe seu telefone.';
                        if (value.length < 10) return 'Telefone muito curto.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Divider(color: primaryAppColor.withOpacity(0.5)),
                    const SizedBox(height: 30),
                    Text(
                      'Seu Endereço',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryAppColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _cepController, 'CEP', Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 8, onChanged: (value) {
                      if (value.length == 8) {
                        _buscarCep(value);
                        FocusScope.of(context).unfocus();
                      }
                    }, validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Por favor, informe o CEP.';
                      if (value.length != 8) return 'O CEP deve ter 8 dígitos.';
                      return null;
                    }),
                    _buildTextField(
                        _logradouroController, 'Logradouro', Icons.map_outlined,
                        readOnly: true),
                    _buildTextField(
                        _numeroController, 'Número', Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, informe o número.'
                            : null),
                    _buildTextField(
                        _bairroController, 'Bairro', Icons.landscape_outlined,
                        readOnly: true),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_cidadeController, 'Cidade',
                              Icons.location_city_outlined,
                              readOnly: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              _estadoController, 'UF', Icons.flag_outlined,
                              readOnly: true, maxLength: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(color: primaryAppColor.withOpacity(0.5)),
                    const SizedBox(height: 30),
                    Text(
                      'Sobre seu Lar e Rotina',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryAppColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField<String>(
                      'Tipo de Residência',
                      _tipoResidencia,
                      const [
                        DropdownMenuItem(
                            value: 'Casa com quintal',
                            child: Text('Casa com quintal')),
                        DropdownMenuItem(
                            value: 'Casa sem quintal',
                            child: Text('Casa sem quintal')),
                        DropdownMenuItem(
                            value: 'Apartamento', child: Text('Apartamento')),
                        DropdownMenuItem(
                            value: 'Fazenda/Sítio',
                            child: Text('Fazenda/Sítio')),
                      ],
                      (value) {
                        setState(() {
                          _tipoResidencia = value;
                          if (value != 'Apartamento') {
                            _possuiTelaProtecao =
                                false; // Reseta se não for apartamento
                          }
                        });
                      },
                    ),
                    if (_tipoResidencia == 'Apartamento')
                      _buildCheckboxListTile(
                        'Possui tela de proteção em janelas/sacadas?',
                        'Isso é fundamental para a segurança do pet em apartamentos.',
                        _possuiTelaProtecao,
                        (value) => setState(
                            () => _possuiTelaProtecao = value ?? false),
                      ),
                    _buildCheckboxListTile(
                      'Todos os moradores da residência estão de acordo com a adoção?',
                      'O consentimento de todos é vital para o bem-estar do pet.',
                      _todosDeAcordo,
                      (value) =>
                          setState(() => _todosDeAcordo = value ?? false),
                    ),
                    _buildDropdownField<String>(
                      'Possui outros pets atualmente?',
                      _outrosPets,
                      const [
                        DropdownMenuItem(
                            value: 'Não tenho pets',
                            child: Text('Não tenho pets')),
                        DropdownMenuItem(
                            value: 'Sim, outros cães',
                            child: Text('Sim, outros cães')),
                        DropdownMenuItem(
                            value: 'Sim, gatos', child: Text('Sim, gatos')),
                        DropdownMenuItem(
                            value: 'Sim, cães e gatos',
                            child: Text('Sim, cães e gatos')),
                        DropdownMenuItem(
                            value: 'Sim, outros tipos de pets',
                            child: Text('Sim, outros tipos de pets')),
                      ],
                      (value) => setState(() => _outrosPets = value),
                    ),
                    _buildDropdownField<String>(
                      'Qual sua experiência anterior com pets?',
                      _experienciaAnterior,
                      const [
                        DropdownMenuItem(
                            value: 'Nunca tive', child: Text('Nunca tive')),
                        DropdownMenuItem(
                            value: 'Tive no passado',
                            child: Text('Tive no passado')),
                        DropdownMenuItem(
                            value: 'Tenho atualmente',
                            child: Text('Tenho atualmente')),
                        DropdownMenuItem(
                            value: 'Sou protetor/voluntário',
                            child: Text('Sou protetor/voluntário')),
                      ],
                      (value) => setState(() => _experienciaAnterior = value),
                    ),
                    _buildDropdownField<int>(
                      'Quantas horas o pet ficaria sozinho por dia?',
                      _horasSozinho,
                      const [
                        DropdownMenuItem(
                            value: 0,
                            child: Text('Quase nunca (menos de 1 hora)')),
                        DropdownMenuItem(value: 1, child: Text('1 a 3 horas')),
                        DropdownMenuItem(value: 4, child: Text('4 a 6 horas')),
                        DropdownMenuItem(
                            value: 7, child: Text('Mais de 6 horas')),
                      ],
                      (value) => setState(() => _horasSozinho = value),
                    ),
                    _buildDropdownField<String>(
                      'Quem cuidaria do pet em caso de viagens?',
                      _cuidadorViagens,
                      const [
                        DropdownMenuItem(
                            value: 'Ficaria com familiares/amigos',
                            child: Text('Ficaria com familiares/amigos')),
                        DropdownMenuItem(
                            value: 'Hospedagem para pets',
                            child: Text('Hospedagem para pets')),
                        DropdownMenuItem(
                            value: 'Levarei comigo',
                            child: Text('Levarei comigo')),
                        DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                      ],
                      (value) => setState(() => _cuidadorViagens = value),
                    ),
                    const SizedBox(height: 30),
                    Divider(color: primaryAppColor.withOpacity(0.5)),
                    const SizedBox(height: 30),
                    Text(
                      'Compromisso com o Bem-Estar',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryAppColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCheckboxListTile(
                      'Estou ciente dos custos com alimentação, veterinário e higiene.',
                      'Pets precisam de cuidados contínuos e investimento financeiro.',
                      _conscienteCustos,
                      (value) =>
                          setState(() => _conscienteCustos = value ?? false),
                    ),
                    _buildCheckboxListTile(
                      'Comprometo-me a oferecer passeios diários e socialização adequada.',
                      'Cães precisam de exercícios e interação para uma vida saudável e feliz.',
                      _conscienteRotina,
                      (value) =>
                          setState(() => _conscienteRotina = value ?? false),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _adotarCachorro,
                        icon: _loading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 28),
                        label: Text(
                          _loading ? 'Enviando...' : 'Confirmar Solicitação',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAppColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: primaryAppColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
