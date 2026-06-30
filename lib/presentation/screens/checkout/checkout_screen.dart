import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _selectedPayment = 'Transfer Bank';
  bool _isProcessing = false;

  final _paymentMethods = [
    {'key': 'Transfer Bank', 'icon': '🏦', 'desc': 'BCA / Mandiri / BNI / BRI'},
    {'key': 'QRIS', 'icon': '📲', 'desc': 'Scan QR dari semua e-wallet'},
    {'key': 'COD', 'icon': '🚚', 'desc': 'Bayar saat barang tiba'},
    {'key': 'GoPay', 'icon': '💚', 'desc': 'GoPay / OVO / Dana'},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _addressCtrl.text = '${user.name} – masukkan alamat lengkap';
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    final order = {
      'id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'status': 'Diproses',
      'total': cart.totalIDR,
      'payment': _selectedPayment,
      'address': _addressCtrl.text.trim(),
      'items': cart.items
          .map((item) => {
                'title': item.product.title,
                'quantity': item.quantity,
                'price': item.subtotalIDR,
              })
          .toList(),
    };

    await context.read<AuthProvider>().saveOrder(order);
    await context.read<CartProvider>().clearCart();
    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Center(
                child: Icon(Icons.check_circle,
                    color: AppTheme.primary, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pesanan Berhasil!',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Terima kasih telah berbelanja.\nPesananmu sedang diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (_) => false);
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pesanan')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Informasi penerima ──────────────────────────────────────
              _sectionTitle('Informasi Penerima'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(Icons.person_outline,
                          auth.user?.name ?? '-', 'Nama'),
                      const Divider(height: 20),
                      _infoRow(Icons.phone_outlined,
                          auth.user?.phone ?? '-', 'No. HP'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Alamat ──────────────────────────────────────────────────
              _sectionTitle('Alamat Pengiriman'),
              TextFormField(
                controller: _addressCtrl,
                validator: Validators.address,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Masukkan alamat lengkap (jalan, kota, kode pos)',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Metode Pembayaran ────────────────────────────────────────
              _sectionTitle('Metode Pembayaran'),
              ...(_paymentMethods.map((pm) {
                final selected = _selectedPayment == pm['key'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedPayment = pm['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withOpacity(0.07)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : Colors.grey[300]!,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(pm['icon']!,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pm['key']!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? AppTheme.primary
                                          : AppTheme.textDark)),
                              Text(pm['desc']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey)),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: AppTheme.primary),
                      ],
                    ),
                  ),
                );
              })),
              const SizedBox(height: 16),

              // ── Catatan ─────────────────────────────────────────────────
              _sectionTitle('Catatan (Opsional)'),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Misal: taruh di depan pintu',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Ringkasan ───────────────────────────────────────────────
              _sectionTitle('Ringkasan Pesanan'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                )),
                                Text('×${item.quantity}',
                                    style: const TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: 13)),
                                const SizedBox(width: 8),
                                Text(
                                  CurrencyFormatter.formatIDR(
                                      item.subtotalIDR),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      _summaryRow('Subtotal',
                          CurrencyFormatter.formatIDR(cart.subtotalIDR)),
                      _summaryRow('PPN 11%',
                          CurrencyFormatter.formatIDR(cart.taxIDR)),
                      _summaryRow('Ongkir', 'Gratis',
                          valueColor: Colors.green),
                      const Divider(),
                      _summaryRow(
                          'Total',
                          CurrencyFormatter.formatIDR(cart.totalIDR),
                          bold: true,
                          valueColor: AppTheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Tombol Bayar ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Memproses Pembayaran...'),
                          ],
                        )
                      : Text('Bayar ${CurrencyFormatter.formatIDR(cart.totalIDR)}'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
      );

  Widget _infoRow(IconData icon, String value, String label) => Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textGrey)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      );

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.normal,
                    color: AppTheme.textDark)),
            Text(value,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.w800 : FontWeight.w600,
                    color: valueColor ?? AppTheme.textDark,
                    fontSize: bold ? 16 : 14)),
          ],
        ),
      );
}
