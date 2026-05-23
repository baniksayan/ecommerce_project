import 'package:flutter/material.dart';

import '../common/pages/no_internet_page.dart';
import '../core/network/network_error_utils.dart';
import '../models/product_details_model.dart';
import '../services/api_service.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ApiService _apiService = ApiService();
  late Future<Productdetails> _detailsFuture;

  int _activeIndex = 0;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getProductDetails(widget.productId);
  }

  Future<void> _refresh() async {
    final future = _apiService.getProductDetails(widget.productId);
    setState(() => _detailsFuture = future);
    await future;
  }

  Future<void> _retryDetailsLoad() async {
    setState(() => _retryCount++);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Productdetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (isNetworkError(snapshot.error)) {
              return NoInternetPage(
                retryCount: _retryCount,
                onRetry: () {
                  _retryDetailsLoad();
                },
              );
            }
            return _DetailErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final details = snapshot.data?.data;
          if (details == null) {
            return _DetailErrorState(
              message: 'Product details not found.',
              onRetry: _refresh,
            );
          }

          final images = (details.images ?? <String>[])
              .map(_apiService.resolveImageUrl)
              .where((e) => e.trim().isNotEmpty)
              .toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildImageSlider(images),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (details.name ?? '').trim().isEmpty
                            ? 'Unnamed Product'
                            : details.name!.trim(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      _metaChip(
                        context,
                        (details.categoryName ?? '').trim().isEmpty
                            ? 'Uncategorized'
                            : details.categoryName!.trim(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(details.price),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          if ((details.discountPrice ?? '').trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                _formatPrice(details.discountPrice),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('SKU', details.sku),
                      _buildInfoRow(
                        'Stock',
                        _stockText(details.stockQuantity, details.stock),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (details.description ?? '').trim().isEmpty
                            ? 'No description available.'
                            : details.description!.trim(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _activeIndex = index),
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activeIndex == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: _activeIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    final displayValue = (value ?? '').trim().isEmpty ? 'N/A' : value!.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatPrice(String? rawPrice) {
    if ((rawPrice ?? '').trim().isEmpty) {
      return 'Price unavailable';
    }
    return 'Rs ${rawPrice!.trim()}';
  }

  String _stockText(int? stockQuantity, int? stock) {
    final resolved = stockQuantity ?? stock;
    if (resolved == null) return 'Unknown';
    if (resolved <= 0) return 'Out of stock';
    return '$resolved available';
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
