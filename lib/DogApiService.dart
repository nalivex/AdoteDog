import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchBreedInfo(String breedName) async {
  final url =
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$breedName');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    if (data.isNotEmpty) {
      return data[0];
    }
  }

  return null;
}
