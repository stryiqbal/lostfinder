import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';

class ApiService {
  // Catatan IP:
  // - Chrome/Web/Windows: 'http://127.0.0.1:8000/api'
  // - Android Emulator: 'http://10.0.2.2:8000/api'
  // - HP Fisik: Pakai IP Laptop (misal 'http://192.168.1.X:8000/api')
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  static String get storageBaseUrl {
    return baseUrl.replaceAll('/api', '');
  }

  static String resolvePhotoUrl(String? rawPhoto) {
    if (rawPhoto == null || rawPhoto.toString().trim().isEmpty) {
      return '';
    }

    final photo = rawPhoto.toString().trim();
    String url;

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      url = photo;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        url = url
            .replaceFirst('127.0.0.1', '10.0.2.2')
            .replaceFirst('localhost', '10.0.2.2');
      }
      return _appendCacheBuster(url);
    }

    if (photo.startsWith('/storage/')) {
      url = '$storageBaseUrl$photo';
    } else if (photo.startsWith('storage/')) {
      url = '$storageBaseUrl/$photo';
    } else {
      url = '$storageBaseUrl/storage/$photo';
    }

    return _appendCacheBuster(url);
  }

  static String _appendCacheBuster(String url) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  // --- API LOGIN ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- API LOGOUT ---
  static Future<bool> logout() async {
    return true;
  }

  // --- API REGISTER ---
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
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
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- API GET PROFILE ---
  static Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return data['data'];
        }
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getUserProfile: $e');
      return null;
    }
  }

  // --- API UPDATE PROFILE (MENDUKUNG FOTO & DATA DIRI) ---
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? phone,
    String? bio,
    XFile? photoFile, // Berkas gambar profil
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST', // Menggunakan POST agar kompatibel dengan upload multipart Laravel
        Uri.parse('$baseUrl/users/$userId'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Menambahkan text form field
      request.fields['name'] = name;
      request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (bio != null) request.fields['bio'] = bio;

      // Menambahkan foto jika user memilih foto baru
      if (photoFile != null) {
        final bytes = await photoFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo', // Field 'photo' di backend Laravel/DB
            bytes,
            filename: photoFile.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui!',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui profil.',
        };
      }
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      return {
        'success': false,
        'message': 'Gagal memperbarui profil: $e',
      };
    }
  }

  // --- API RESET / CHANGE PASSWORD ---
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diperbarui!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui password.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi ke server.',
      };
    }
  }

  // --- API FORGOT PASSWORD ---
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Link reset password berhasil dikirim ke email Anda.',
        };
      }

      String errorMessage = 'Email tidak terdaftar di sistem kami!';

      if (data.containsKey('message') && data['message'] != null) {
        errorMessage = data['message'];
      } else if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          errorMessage = errors.values.first[0].toString();
        }
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Periksa koneksi internet/backend Anda.',
      };
    }
  }

  // --- API TAMBAH BARANG (TANPA GAMBAR) ---
  static Future<Map<String, dynamic>> addItem({
    required int userId,
    required String title,
    required String category,
    required String description,
    required String location,
  }) async {
    try {
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
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- API DELETE ITEM ---
  static Future<Map<String, dynamic>> deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/items/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus data'};
    }
  }

  // --- API UPDATE STATUS ---
  static Future<Map<String, dynamic>> updateItemStatus(int id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/items/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengubah status'};
    }
  }

  // --- API TAMBAH BARANG BESERTA GAMBAR (MULTIPART) ---
  static Future<Map<String, dynamic>> addItemWithImage({
    required int userId,
    required String title,
    required String category,
    required String description,
    required String location,
    XFile? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/items'));

      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['location'] = location;

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
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengunggah data: $e'};
    }
  }

  // --- API GET ITEMS ---
  static Future<List<ItemModel>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        List data = body['data'] ?? body;
        return data.map((e) => ItemModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      debugPrint('Error getItems: $e');
      rethrow;
    }
  }
}