import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://meta-spirit-441312-g4.ue.r.appspot.com';

  Future<List<String>> getActiveNumbers(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_active_numbers'));

      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load active numbers: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load active numbers: ${e.toString()}');
    }
  }
}