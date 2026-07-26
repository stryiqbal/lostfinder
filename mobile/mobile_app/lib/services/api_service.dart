import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ApiService {
  // CATATAN: Jika pakai Emulator Android, gunakan http://10.0.2.2:8000/api
  // Jika pakai HP fisik (kabel USB), gunakan IP komputer lokal Anda (misal http://192.168.1.5:8000/api)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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