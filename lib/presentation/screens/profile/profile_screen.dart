import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _isPickingImage = false;
  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final addressesJson = LocalStorageService.getAddressesJson();
    final ordersJson = LocalStorageService.getOrdersJson();
    if (!mounted) return;

    setState(() {
      _addresses = addressesJson != null && addressesJson.isNotEmpty
          ? List<Map<String, dynamic>>.from(jsonDecode(addressesJson))
          : [];
      _orders = ordersJson != null && ordersJson.isNotEmpty
          ? List<Map<String, dynamic>>.from(jsonDecode(ordersJson))
          : [];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 500,
      );
      if (file != null) {
        await LocalStorageService.saveProfileImagePath(file.path);
        if (mounted) {
          context.read<AuthProvider>().updateProfileImage(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui ✅')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengambil foto: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Ubah Foto Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.camera_alt, color: Colors.white)),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFF8F00),
                    child: Icon(Icons.photo_library, color: Colors.white)),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();

    String? nameValue;
    String? phoneValue;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Data Diri'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              nameValue = nameCtrl.text.trim();
              phoneValue = phoneCtrl.text.trim();
              Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();

    if (result == true && mounted) {
      try {
        await context.read<AuthProvider>().updateProfile(
          name: nameValue ?? user.name,
          phone: phoneValue ?? user.phone,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data diri berhasil diperbarui ✅')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _showPasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? currentPasswordValue;
    String? newPasswordValue;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Saat Ini'),
                validator: (value) => (value == null || value.isEmpty) ? 'Password saat ini wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
                validator: (value) => (value == null || value.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                validator: (value) => (value != newCtrl.text) ? 'Konfirmasi password tidak cocok' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                currentPasswordValue = currentCtrl.text;
                newPasswordValue = newCtrl.text;
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();

    if (result == true && mounted) {
      try {
        await context.read<AuthProvider>().changePassword(
          currentPassword: currentPasswordValue ?? '',
          newPassword: newPasswordValue ?? '',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password berhasil diperbarui 🔐')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _showAddressDialog() async {
    final labelCtrl = TextEditingController();
    final recipientCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? labelValue;
    String? recipientValue;
    String? phoneValue;
    String? addressValue;
    String? cityValue;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Alamat'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(labelText: 'Label Alamat'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Label alamat wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: recipientCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Penerima'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama penerima wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor HP'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'Kota'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Kota wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                labelValue = labelCtrl.text.trim();
                recipientValue = recipientCtrl.text.trim();
                phoneValue = phoneCtrl.text.trim();
                addressValue = addressCtrl.text.trim();
                cityValue = cityCtrl.text.trim();
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    labelCtrl.dispose();
    recipientCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();

    if (result == true && mounted) {
      try {
        await context.read<AuthProvider>().addAddress({
          'label': labelValue ?? '',
          'recipientName': recipientValue ?? '',
          'phone': phoneValue ?? '',
          'address': addressValue ?? '',
          'city': cityValue ?? '',
        });
        await _loadProfileData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alamat berhasil ditambahkan 📍')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah alamat: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _showAddressesSheet() async {
    await _loadProfileData();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Alamat Tersimpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddressDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Belum ada alamat tersimpan.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _addresses.length,
                    itemBuilder: (_, index) {
                      final address = _addresses[index];
                      return Card(
                        child: ListTile(
                          title: Text(address['label'] ?? 'Alamat'),
                          subtitle: Text('${address['recipientName'] ?? '-'}\n${address['address'] ?? '-'} ${address['city'] ?? ''}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOrderHistorySheet() async {
    await _loadProfileData();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Riwayat Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (_orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Belum ada riwayat pesanan.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _orders.length,
                    itemBuilder: (_, index) {
                      final order = _orders[index];
                      return Card(
                        child: ListTile(
                          title: Text(order['id'] ?? 'Pesanan'),
                          subtitle: Text('${order['status'] ?? '-'} • ${order['date'] != null ? DateTime.tryParse(order['date'].toString())?.toLocal().toString().split(' ')[0] : '-'}'),
                          trailing: Text('Rp ${order['total'] ?? 0}'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun?'),
        content: const Text('Kamu akan keluar dari akun ini. Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<CartProvider>().clearCart();
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: user?.profileImagePath != null
                                ? Image.file(
                                    File(user!.profileImagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _avatarFallback(user),
                                  )
                                : _avatarFallback(user),
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8F00),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Pengguna',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _statCard('🛒', '${cart.itemCount}', 'Item\nKeranjang'),
                  const SizedBox(width: 12),
                  _statCard('📦', '${_orders.length}', 'Pesanan\nAktif'),
                  const SizedBox(width: 12),
                  _statCard('❤️', '0', 'Produk\nFavorit'),
                ],
              ),
            ),

            _menuSection('Akun Saya', [
              _menuItem(Icons.person_outline, 'Data Diri', _showEditProfileDialog),
              _menuItem(Icons.lock_outline, 'Ubah Password', _showPasswordDialog),
              _menuItem(Icons.location_on_outlined, 'Alamat Tersimpan', _showAddressesSheet),
            ]),
            const SizedBox(height: 8),
            _menuSection('Transaksi', [
              _menuItem(Icons.shopping_bag_outlined, 'Riwayat Pesanan', _showOrderHistorySheet),
              _menuItem(Icons.rate_review_outlined, 'Ulasan Saya', () {}),
            ]),
            const SizedBox(height: 8),
            _menuSection('Lainnya', [
              _menuItem(Icons.help_outline, 'Pusat Bantuan', () {}),
              _menuItem(Icons.info_outline, 'Tentang Aplikasi', () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Pasar Lokal',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Pasar Lokal\nMarketplace UMKM Digital Indonesia',
                );
              }),
            ]),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Keluar Akun', style: TextStyle(color: AppTheme.error)),
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback(user) => Container(
        color: AppTheme.primary.withOpacity(0.2),
        child: Center(
          child: Text(
            (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
        ),
      );

  Widget _statCard(String emoji, String value, String label) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
              ],
            ),
          ),
        ),
      );

  Widget _menuSection(String title, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(title,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: items),
          ),
        ],
      );

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
        onTap: onTap,
      );
}
