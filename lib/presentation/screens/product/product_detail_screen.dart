import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../routes/app_routes.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
      body: switch (pp.detailStatus) {
        ProductStatus.loading => const Center(child: CircularProgressIndicator()),
        ProductStatus.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                Text(pp.errorMessage ?? 'Gagal memuat produk',
                    style: const TextStyle(color: AppTheme.textGrey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      pp.loadProductDetail(widget.productId),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        _ => pp.selectedProduct == null
            ? const SizedBox.shrink()
            : _buildBody(context, pp, cart),
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider pp, CartProvider cart) {
    final product = pp.selectedProduct!;
    final inCart = cart.isInCart(product.id);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Gambar ─────────────────────────────────────────────────
                Container(
                  height: 300,
                  color: Colors.white,
                  width: double.infinity,
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined,
                              size: 80, color: Colors.grey),
                    ),
                  ),
                ),
                // ── Info utama ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nama produk
                      Text(product.title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              height: 1.3)),
                      const SizedBox(height: 10),
                      // Rating & jumlah terjual
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < product.rating.rate.floor()
                                  ? Icons.star
                                  : i < product.rating.rate
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating.rate} ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text('(${product.rating.count} ulasan)',
                              style: const TextStyle(
                                  color: AppTheme.textGrey, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Harga
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok tersedia: ${product.stock} unit',
                        style: const TextStyle(
                            color: AppTheme.textGrey, fontSize: 13),
                      ),
                      const Divider(height: 28),
                      // Deskripsi
                      const Text('Deskripsi Produk',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      Text(product.description,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                              height: 1.6)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom bar ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            children: [
              // Qty selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed:
                          _qty > 1 ? () => setState(() => _qty--) : null,
                    ),
                    Text('$_qty',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => setState(() => _qty++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Tambah ke keranjang
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(inCart
                      ? Icons.shopping_cart
                      : Icons.add_shopping_cart),
                  label: Text(
                      inCart ? 'Tambah Lagi (+$_qty)' : 'Tambah ke Keranjang'),
                  onPressed: () {
                    context
                        .read<CartProvider>()
                        .addToCart(product, qty: _qty);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$_qty item ditambahkan ke keranjang!'),
                        action: SnackBarAction(
                          label: 'Lihat',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.cart),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
