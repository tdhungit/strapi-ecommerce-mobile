import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/components/product_category_component.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Map<String, dynamic> _category = {};

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      final categoryId = widget.categoryId;
      final data = await ApiService.request(
        '/api/sale-categories/$categoryId',
        'GET',
        options: {'noAuth': true},
      );
      if (mounted) {
        setState(() {
          _category = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _category = {};
        });
        print('Error fetching category: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_category['name'] ?? 'Category')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _category.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ProductCategoryComponent(productCategory: _category),
        ),
      ),
    );
  }
}
