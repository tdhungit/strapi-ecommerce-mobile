import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  dynamic _product;

  @override
  void initState() {
    super.initState();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(
        child: _product != null
            ? Text(_product['name'])
            : const CircularProgressIndicator(),
      ),
    );
  }
}
