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
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  int _page = 1;
  // int _limit = 10;

  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _getData() async {
    try {
      final categoryId = widget.categoryId;
      final data = await ApiService.collection(
        'product-categories',
        categoryId,
        options: {'noAuth': true},
      );
      if (mounted) {
        setState(() {
          _category = data['data'];
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

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _page = 1;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _page++;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_category['name'] ?? 'Category')),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: _searchProducts,
              ),

              SizedBox(height: 20),
              _category.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ProductCategoryComponent(
                      productCategory: _category,
                      queryParams: (
                        keyword: _searchQuery,
                        page: _page,
                        limit: 10,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
