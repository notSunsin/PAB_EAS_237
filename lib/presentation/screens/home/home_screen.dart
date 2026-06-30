import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/product_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.status == ProductStatus.initial) p.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pasar Lokal'),
        actions: [
          badges.Badge(
            badgeContent: Text(
              '${cart.itemCount}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            showBadge: cart.itemCount > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().refresh(),
        child: CustomScrollView(
          slivers: [
            // ── Banner selamat datang ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${auth.user?.name.split(' ').first ?? 'Sobat'}! 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          const Text('Temukan produk UMKM terbaik hari ini',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Text('🏪', style: TextStyle(fontSize: 44)),
                  ],
                ),
              ),
            ),

            // ── Search bar ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      context.read<ProductProvider>().search(v),
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<ProductProvider>().search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // ── Kategori ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: products.status == ProductStatus.loading
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: products.categories.map((cat) {
                          final selected =
                              products.selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _categoryLabel(cat),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textDark,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) =>
                                  context
                                      .read<ProductProvider>()
                                      .selectCategory(cat),
                              backgroundColor: Colors.white,
                              selectedColor: AppTheme.primary,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: selected
                                    ? AppTheme.primary
                                    : Colors.grey[300]!,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),

            // ── Jumlah produk ditemukan ────────────────────────────────────
            if (products.status == ProductStatus.loaded)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '${products.products.length} produk ditemukan',
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 13),
                  ),
                ),
              ),

            // ── Konten utama ───────────────────────────────────────────────
            if (products.status == ProductStatus.loading)
              const SliverToBoxAdapter(child: ProductGridShimmer())
            else if (products.status == ProductStatus.error)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(products.errorMessage ?? 'Terjadi kesalahan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        onPressed: () =>
                            context.read<ProductProvider>().refresh(),
                      ),
                    ],
                  ),
                ),
              )
            else if (products.products.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔍', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('Produk tidak ditemukan',
                          style: TextStyle(color: AppTheme.textGrey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final product = products.products[i];
                      return ProductCard(
                        product: product,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.productDetail,
                            arguments: product.id),
                        onAddToCart: () {
                          context.read<CartProvider>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${product.title.length > 25 ? '${product.title.substring(0, 25)}...' : product.title} ditambahkan ke keranjang'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Lihat',
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: products.products.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String cat) {
    if (cat == 'semua') return '🛍️ Semua';
    final map = {
      "men's clothing": "👔 Pria",
      "women's clothing": "👗 Wanita",
      'jewelery': '💍 Perhiasan',
      'electronics': '📱 Elektronik',
    };
    return map[cat] ?? cat;
  }
}
