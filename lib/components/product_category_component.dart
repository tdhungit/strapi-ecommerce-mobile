import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/components/product_block_component.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';
import 'package:strapi_ecommerce_flutter/services/auth_service.dart';

typedef ProductCategoryQueryParams = ({String? keyword, int? limit, int? page});
typedef ProductCategoryOptions = ({bool showAllButton});

class ProductCategoryComponent extends StatefulWidget {
  const ProductCategoryComponent({
    super.key,
    required this.productCategory,
    this.queryParams,
    this.options,
  });

  final Map<String, dynamic> productCategory;
  final ProductCategoryQueryParams? queryParams;
  final ProductCategoryOptions? options;

  @override
  State<ProductCategoryComponent> createState() =>
      _ProductCategoryComponentState();
}

class _ProductCategoryComponentState extends State<ProductCategoryComponent> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void didUpdateWidget(covariant ProductCategoryComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.queryParams != oldWidget.queryParams) {
      if ((widget.queryParams?.page ?? 1) == 1) {
        setState(() {
          _isLoading = true;
        });
      }
      _getData();
    }
  }

  Future<void> _getData() async {
    try {
      final warehouseId = await AuthService.storage.read(
        key: 'selected_warehouse_id',
      );
      final categoryId = widget.productCategory['id'];
      final keyword = widget.queryParams?.keyword ?? '';
      final limit = widget.queryParams?.limit ?? 10;
      final page = widget.queryParams?.page ?? 1;
      final data = await ApiService.request(
        '/api/sale-products',
        'GET',
        options: {'noAuth': true},
        data: {
          'warehouseId': warehouseId.toString(),
          'categoryId': categoryId.toString(),
          'keyword': keyword,
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );
      if (mounted) {
        setState(() {
          final newProducts = data['data'] is List ? data['data'] : [];
          if (page > 1) {
            _products.addAll(newProducts);
          } else {
            _products = newProducts;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching products: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.productCategory['name'] ?? 'Category',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.options?.showAllButton == true)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/category/${widget.productCategory['documentId']}',
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            return ProductBlockComponent(product: _products[index]);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
