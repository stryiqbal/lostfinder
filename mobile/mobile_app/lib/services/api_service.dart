import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Sesuaikan jika pakai emulator/HP

  // --- API LOGIN ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // --- API REGISTER ---
  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    return jsonDecode(response.body);
  }

  // --- API GET ITEMS ---
  static Future<List<ItemModel>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['data'];
      return data.map((e) => ItemModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }
}