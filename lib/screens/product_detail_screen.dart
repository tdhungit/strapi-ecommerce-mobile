import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';
import 'package:strapi_ecommerce_flutter/utils/utils.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  dynamic _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    fetchProduct();
  }

  Future<dynamic> fetchProduct() async {
    final id = widget.productId;
    final response = await ApiService.request(
      '/api/sale-products/$id',
      'GET',
      options: {'noAuth': true},
    );
    setState(() {
      _product = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(body: Center(child: Text('Product not found')));
    }

    final photoUrl = productImageUrl(_product['photos']);
    return Scaffold(
      appBar: AppBar(title: Text(_product['name'])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              child: photoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product['name'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_product['from_price'] ?? '0.00'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: _product['description'] ?? '',
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        color: Colors.black54,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.5),
                        fontFamily: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.fontFamily,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
