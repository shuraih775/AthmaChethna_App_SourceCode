import 'dart:convert';
import 'package:http/http.dart' as http;

class MongoDBService {
  static const String baseUrl = "http://192.168.0.111:5000";

  static Future<Map<String, dynamic>> signupUser(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    return jsonDecode(response.body);
  }
}
