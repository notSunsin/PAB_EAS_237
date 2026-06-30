import 'dart:convert';

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/local_storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Cek sesi saat app start ────────────────────────────────────────────────
  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repo.login(email, password);
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── REGISTER ───────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── UPDATE PROFIL LOKAL ───────────────────────────────────────────────────
  void updateProfileImage(String path) {
    if (_user != null) {
      _user = _user!.copyWith(profileImagePath: path);
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    if (_user == null) throw Exception('User belum login');
    final updatedUser = _user!.copyWith(name: name, phone: phone);
    await LocalStorageService.saveUser(updatedUser.toJsonString());
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) throw Exception('User belum login');
    final registeredJson = LocalStorageService.getRegisteredUsers();
    if (registeredJson == null) throw Exception('Data akun tidak ditemukan');

    final list = List<Map<String, dynamic>>.from(jsonDecode(registeredJson));
    final index = list.indexWhere(
      (u) => u['email'] == _user!.email && u['password'] == currentPassword,
    );

    if (index == -1) throw Exception('Password saat ini salah');

    list[index]['password'] = newPassword;
    await LocalStorageService.saveRegisteredUsers(jsonEncode(list));
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    final addressesJson = LocalStorageService.getAddressesJson();
    final addresses = addressesJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(addressesJson))
        : <Map<String, dynamic>>[];

    addresses.add(address);
    await LocalStorageService.saveAddresses(jsonEncode(addresses));
  }

  Future<List<Map<String, dynamic>>> getSavedAddresses() async {
    final addressesJson = LocalStorageService.getAddressesJson();
    if (addressesJson == null || addressesJson.isEmpty) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(addressesJson));
  }

  Future<void> saveOrder(Map<String, dynamic> order) async {
    final ordersJson = LocalStorageService.getOrdersJson();
    final orders = ordersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(ordersJson))
        : <Map<String, dynamic>>[];

    orders.insert(0, order);
    await LocalStorageService.saveOrders(jsonEncode(orders));
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    final ordersJson = LocalStorageService.getOrdersJson();
    if (ordersJson == null || ordersJson.isEmpty) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(ordersJson));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
