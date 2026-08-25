// =============================================================================
// FILE: lib/services/api_service.dart
// FUNGSI: Service Pengelola Komunikasi REST API (HTTP Request GET, POST, DELETE, Multipart)
// PATTERN: Utility Helper Class dengan Dynamic Base URL Resolution
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Kelas Helper Pengelola HTTP Communication ke Backend Server Laravel / Node.js
class ApiService {
  // Alamat Server Tunneling Ngrok (Publik)
  static const String _ngrokUrl = 'https://nectar-refinish-console.ngrok-free.dev';

  // FUNGSI 1: Resolver Otomatis Alamat Base URL (Ngrok untuk HP & Web Online)
  static String get baseUrl {
    // Catatan: Diubah ke Ngrok agar versi Web di internet bisa memanggil laptop Kakak
    return '$_ngrokUrl/api';
  }

  // SAKLAR MOCK DATA: Set ke 'true' jika server offline agar aplikasi tetap berjalan dengan data lokal
  static const bool useMockData = false;

  // FUNGSI 2: Header HTTP Standar (JSON & Bearer Token Authentication)
  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Bypass halaman konfirmasi ngrok
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // FUNGSI 3: Permintaan HTTP GET (Mengambil Data dari Server)
  static Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'Tidak dapat terhubung ke server: $e'}), 503);
    }
  }

  // FUNGSI 4: Permintaan HTTP POST (Mengirim Data / Form ke Server)
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'Gagal mengirim data ke server: $e'}), 503);
    }
  }

  // FUNGSI 5: Permintaan HTTP PATCH (Memperbarui Data Sebagian di Server)
  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.patch(
        url,
        headers: _headers(token),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'Gagal memperbarui data di server: $e'}), 503);
    }
  }

  // FUNGSI 6: Permintaan HTTP DELETE (Menghapus Data di Server)
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.delete(
        url,
        headers: _headers(token),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'Gagal menghapus data di server: $e'}), 503);
    }
  }

  // FUNGSI 6: Permintaan HTTP MULTIPART POST (Mengunggah Dokumen Foto / File Berkas)
  static Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
    {String? token}
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(_headers(token));
      request.fields.addAll(fields);

      for (var entry in files.entries) {
        if (entry.value.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      return http.Response(jsonEncode({'message': 'Gagal upload ke server: $e'}), 503);
    }
  }
}
