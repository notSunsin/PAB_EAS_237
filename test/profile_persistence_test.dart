import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_lokal/data/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('menyimpan dan memuat daftar alamat', () async {
    final addresses = [
      {
        'label': 'Rumah',
        'recipientName': 'Budi',
        'phone': '081234567890',
        'address': 'Jl. Merdeka No. 10',
        'city': 'Bandung',
      }
    ];

    await LocalStorageService.saveAddresses(jsonEncode(addresses));
    final stored = LocalStorageService.getAddressesJson();

    expect(stored, isNotNull);
    expect(jsonDecode(stored!), isA<List>());
    expect(jsonDecode(stored).first['label'], 'Rumah');
  });

  test('menyimpan dan memuat riwayat pesanan', () async {
    final orders = [
      {
        'id': 'ORD-001',
        'date': '2026-06-30',
        'status': 'Selesai',
        'total': 150000,
        'items': ['Kopi Lokal'],
      }
    ];

    await LocalStorageService.saveOrders(jsonEncode(orders));
    final stored = LocalStorageService.getOrdersJson();

    expect(stored, isNotNull);
    expect(jsonDecode(stored!), isA<List>());
    expect(jsonDecode(stored).first['id'], 'ORD-001');
  });
}
