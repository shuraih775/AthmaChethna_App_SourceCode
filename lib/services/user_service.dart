import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class UserService {
  final String baseUrl =
      "http://192.168.0.111:5000/api/user"; // Updated base URL
  final StorageService _storageService = StorageService();

  // ✅ Fetch user data using userId from backend
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      String? userId = await _storageService.getUserId();
      if (userId == null) return null;

      final response = await http.get(Uri.parse('$baseUrl/$userId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        return userData['user'];
      } else {
        print("❌ Failed to fetch user data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔴 Error in fetchUserData: $e");
      return null;
    }
  }

  // ✅ Save username and email securely after login
  Future<void> storeLoginDetails(
    String username,
    String email,
    String userId,
  ) async {
    try {
      await _storageService.saveUsername(username);
      await _storageService.saveEmail(email);
      await _storageService.saveUserId(userId);
      print("✅ Login details saved successfully!");
    } catch (e) {
      print("🔴 Error saving login details: $e");
    }
  }
}
