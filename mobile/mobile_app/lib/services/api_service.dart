import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // 👈 Impor ImagePicker
import '../models/item_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Sesuaikan jika pakai emulator/HP

  // --- API LOGIN ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // --- API REGISTER ---
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
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

  // --- API TAMBAH BARANG (JSON / TANPA GAMBAR) ---
  static Future<Map<String, dynamic>> addItem({
    required int userId,
    required String title,
    required String category,
    required String description,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'category': category,
        'description': description,
        'location': location,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // 📝 FITUR TAMBAH BARANG BESERTA GAMBAR (MULTIPART)
  static Future<Map<String, dynamic>> addItemWithImage({
    required int userId,
    required String title,
    required String category,
    required String description,
    required String location,
    XFile? imageFile, // 👈 Terima file gambar dari ImagePicker
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items'));

    // Kirim text fields
    request.fields['user_id'] = userId.toString();
    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['description'] = description;
    request.fields['location'] = location;

    // Jika ada gambar yang dipilih, masukkan ke request
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
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