import 'dart:convert';
import 'dart:math';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiService _api;
  AuthRepository({ApiService? api}) : _api = api ?? ApiService();

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Coba login via API FakeStore (hanya untuk demo endpoint)
    String token;
    try {
      final res = await _api.post(ApiConstants.authLogin, {
        'username': email,
        'password': password,
      });
      token = res['token'] ?? _generateToken(email);
    } catch (_) {
      // Fallback: validasi dari data lokal (registered users)
      token = await _loginFromLocal(email, password);
    }

    // Ambil user dari storage lokal
    final user = await _findOrCreateUser(email);
    await LocalStorageService.saveToken(token);
    await LocalStorageService.saveUser(user.toJsonString());
    return {'token': token, 'user': user};
  }

  // ── REGISTER ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // Simpan ke daftar registered users lokal
    final registeredJson = LocalStorageService.getRegisteredUsers();
    final List<Map<String, dynamic>> registeredList = registeredJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(registeredJson))
        : [];

    // Cek duplikat email
    final exists = registeredList.any((u) => u['email'] == email);
    if (exists) throw Exception('Email sudah terdaftar');

    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // real app: hash this
      'phone': phone,
    };
    registeredList.add(newUser);
    await LocalStorageService.saveRegisteredUsers(jsonEncode(registeredList));

    // Juga POST ke API sebagai demo integrasi
    try {
      await _api.post(ApiConstants.users, {
        'email': email,
        'username': email.split('@').first,
        'password': password,
        'name': {'firstname': name.split(' ').first, 'lastname': name.split(' ').length > 1 ? name.split(' ').last : ''},
        'phone': phone,
      });
    } catch (_) {
      // ignore API error, data sudah tersimpan lokal
    }

    final token = _generateToken(email);
    final user = UserModel(id: id, name: name, email: email, phone: phone);
    await LocalStorageService.saveToken(token);
    await LocalStorageService.saveUser(user.toJsonString());
    return {'token': token, 'user': user};
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<void> logout() => LocalStorageService.clearSession();

  // ── Cek sesi ───────────────────────────────────────────────────────────────
  Future<UserModel?> getCurrentUser() async {
    final token = LocalStorageService.getToken();
    final userJson = LocalStorageService.getUserJson();
    if (token == null || userJson == null) return null;
    return UserModel.fromJsonString(userJson);
  }

  // ─────────────────────── private helpers ──────────────────────────────────

  String _generateToken(String email) {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'pasar_lokal_token_${email.hashCode}_$rand';
  }

  Future<String> _loginFromLocal(String email, String password) async {
    final registeredJson = LocalStorageService.getRegisteredUsers();
    if (registeredJson == null) throw Exception('Email atau password salah');
    final list = List<Map<String, dynamic>>.from(jsonDecode(registeredJson));
    final match = list.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
    if (match.isEmpty) throw Exception('Email atau password salah');
    return _generateToken(email);
  }

  Future<UserModel> _findOrCreateUser(String email) async {
    // Cari di registered list
    final regJson = LocalStorageService.getRegisteredUsers();
    if (regJson != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(regJson));
      final found = list.firstWhere(
        (u) => u['email'] == email,
        orElse: () => {},
      );
      if (found.isNotEmpty) {
        return UserModel.fromJson(found);
      }
    }
    // Fallback (akun FakeStore demo)
    return UserModel(
      id: email.hashCode.toString(),
      name: email.split('@').first,
      email: email,
      phone: '-',
    );
  }
}
