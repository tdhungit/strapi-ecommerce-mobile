import 'package:flutter/material.dart';

class ProductVariantsComponent extends StatefulWidget {
  const ProductVariantsComponent({
    super.key,
    required this.product,
    this.onVariantSelected,
  });

  final dynamic product;
  final Function(dynamic variant)? onVariantSelected;

  @override
  State<ProductVariantsComponent> createState() =>
      _ProductVariantsComponentState();
}

class _ProductVariantsComponentState extends State<ProductVariantsComponent> {
  dynamic _selectedVariant;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> variants = widget.product['product_variants'];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        itemBuilder: (context, index) {
          final variant = variants[index];
          final prices = variant['product_prices'];
          double price = 0;
          if (prices.isNotEmpty) {
            price = prices.first['price']?.toDouble() ?? 0.0;
          }
          String name = '';
          final List<dynamic> attributes =
              variant['product_variant_attributes'];
          if (attributes.isNotEmpty) {
            name = attributes
                .map(
                  (attr) =>
                      "${attr['product_attribute']['name']}: ${attr['attribute_value']}",
                )
                .join(', ');
          }
          return Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariant = variant;
                });
                widget.onVariantSelected?.call(variant);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _selectedVariant == variant
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedVariant == variant
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$$price',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _selectedVariant == variant
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
