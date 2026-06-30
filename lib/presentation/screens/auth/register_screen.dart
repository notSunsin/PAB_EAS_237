import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      context.read<CartProvider>().loadCart();
      context.read<ProductProvider>().loadProducts();
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Registrasi gagal'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lengkapi Data Diri',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                const SizedBox(height: 4),
                const Text('Daftar sekarang dan mulai belanja produk UMKM lokal',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Nomor HP',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscure: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Konfirmasi Password',
                  controller: _confirmPassCtrl,
                  obscure: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passCtrl.text),
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _register,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Daftar Sekarang'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ',
                          style: TextStyle(color: AppTheme.textGrey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Masuk',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
