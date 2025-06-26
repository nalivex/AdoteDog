import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchAllBreeds() async {
  final response =
      await http.get(Uri.parse('https://api.thedogapi.com/v1/breeds'));

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map<String>((item) => item['name'] as String).toList();
  } else {
    throw Exception('Falha ao buscar raças');
  }
}
