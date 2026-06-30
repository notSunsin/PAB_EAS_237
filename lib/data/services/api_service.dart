import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ─── GET ────────────────────────────────────────────────────────────────────
  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final res = await _client
          .get(uri, headers: _headers(token: token))
          .timeout(ApiConstants.timeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server lambat merespons.');
    }
  }

  // ─── POST ───────────────────────────────────────────────────────────────────
  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final res = await _client
          .post(uri,
              headers: _headers(token: token), body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server lambat merespons.');
    }
  }

  // ─── PUT ────────────────────────────────────────────────────────────────────
  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final res = await _client
          .put(uri,
              headers: _headers(token: token), body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server lambat merespons.');
    }
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────────
  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final res = await _client
          .delete(uri, headers: _headers(token: token))
          .timeout(ApiConstants.timeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server lambat merespons.');
    }
  }

  // ─── Handler ────────────────────────────────────────────────────────────────
  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw ApiException('Sesi habis. Silakan login kembali.',
          statusCode: 401);
    } else if (res.statusCode == 404) {
      throw ApiException('Data tidak ditemukan.', statusCode: 404);
    } else if (res.statusCode >= 500) {
      throw ApiException('Terjadi kesalahan pada server. Coba lagi nanti.',
          statusCode: res.statusCode);
    } else {
      throw ApiException('Error ${res.statusCode}: ${res.reasonPhrase}',
          statusCode: res.statusCode);
    }
  }
}
