import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _imageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          final isWishlisted = ref.watch(wishlistProvider.notifier).isWishlisted(product.id);
          final images = product.images.isNotEmpty ? product.images : [product.thumbnail];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 340,
                actions: [
                  IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? AppColors.accent : null,
                    ),
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).toggle(product);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) => setState(() => _imageIndex = index),
                        itemBuilder: (context, index) => CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _imageIndex == index ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _imageIndex == index
                                      ? AppColors.primary
                                      : Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.ratingStar, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            product.stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined,
                            size: 16,
                            color: product.stock > 0 ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                            style: TextStyle(
                              color: product.stock > 0 ? AppColors.success : AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: subTextColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.discountBadge,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage.round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(color: subTextColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          Container(
                            width: 48,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // space for the bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Could not load this product.', style: TextStyle(color: subTextColor)),
        ),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: product.stock == 0
                    ? null
                    : () {
                        ref.read(cartProvider.notifier).addToCart(product, quantity: _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () => context.push(AppRoutes.cart),
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(product.stock == 0 ? 'Out of Stock' : 'Add to Cart'),
              ),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: onTap == null ? borderColor : null),
      ),
    );
  }
}