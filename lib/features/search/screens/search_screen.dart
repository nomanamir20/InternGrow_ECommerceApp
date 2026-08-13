import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/widgets/product_card.dart';
import '../../product/providers/product_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: subTextColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                  child: Icon(Icons.close, color: subTextColor, size: 18),
                ),
            ],
          ),
        ),
      ),
      body: query.trim().isEmpty
          ? Center(
              child: Text(
                'Start typing to search products',
                style: TextStyle(color: subTextColor),
              ),
            )
          : resultsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: subTextColor),
                          const SizedBox(height: 12),
                          Text(
                            'No products found for "$query"',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isWishlisted = wishlist.any((p) => p.id == product.id);
                    return ProductCard(
                      product: product,
                      isWishlisted: isWishlisted,
                      onTap: () => context.push('${AppRoutes.productDetails}/${product.id}'),
                      onWishlistTap: () {
                        ref.read(wishlistProvider.notifier).toggle(product);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Something went wrong searching.', style: TextStyle(color: subTextColor)),
              ),
            ),
    );
  }
}