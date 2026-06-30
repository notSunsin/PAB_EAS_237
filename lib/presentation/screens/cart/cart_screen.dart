import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Kosongkan',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return CartItemCard(
                        item: item,
                        onIncrement: () =>
                            cart.increment(item.product.id),
                        onDecrement: () =>
                            cart.decrement(item.product.id),
                        onRemove: () =>
                            cart.removeItem(item.product.id),
                      );
                    },
                  ),
                ),
                // ── Ringkasan & Checkout ─────────────────────────────────
                _OrderSummary(cart: cart),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kosongkan Keranjang?'),
        content: const Text('Semua item akan dihapus dari keranjang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('Keranjangmu masih kosong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Yuk, mulai belanja produk UMKM lokal!',
              style: TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.store_outlined),
            label: const Text('Belanja Sekarang'),
            onPressed: () => Navigator.pushReplacementNamed(
                context, AppRoutes.home),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        children: [
          _row('Subtotal (${cart.itemCount} item)',
              CurrencyFormatter.formatIDR(cart.subtotalIDR)),
          const SizedBox(height: 6),
          _row('PPN 11%', CurrencyFormatter.formatIDR(cart.taxIDR),
              sub: true),
          const Divider(height: 20),
          _row('Total Pembayaran',
              CurrencyFormatter.formatIDR(cart.totalIDR),
              bold: true, priceColor: AppTheme.primary),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.checkout),
              child: const Text('Lanjut ke Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, bool sub = false, Color? priceColor}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
      fontSize: bold ? 16 : 14,
      color: sub ? AppTheme.textGrey : AppTheme.textDark,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(color: priceColor)),
      ],
    );
  }
}
