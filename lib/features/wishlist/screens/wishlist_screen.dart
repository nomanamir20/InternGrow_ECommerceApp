import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home/widgets/product_card.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearAll(context, ref),
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: subTextColor),
                    const SizedBox(height: 16),
                    Text(
                      'Your wishlist is empty',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return ProductCard(
                  product: product,
                  isWishlisted: true,
                  onTap: () => context.push('${AppRoutes.productDetails}/${product.id}'),
                  onWishlistTap: () {
                    ref.read(wishlistProvider.notifier).toggle(product);
                  },
                );
              },
            ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Toggle off every current item — reuses the existing toggle logic
      // rather than needing a separate "clear all" method on the notifier.
      final currentItems = List.of(ref.read(wishlistProvider));
      for (final product in currentItems) {
        ref.read(wishlistProvider.notifier).toggle(product);
      }
    }
  }
}