import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/components/drawer_component.dart';
import 'package:strapi_ecommerce_flutter/components/product_category_component.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _data = {};
  List<dynamic> _warehouses =
      []; // Changed to dynamic to avoid cast issues, or keep as is if confident
  int? _selectedWarehouseId;

  Future<void> _getData() async {
    try {
      final data = await ApiService.request(
        '/api/home-page',
        'GET',
        data: {'populate': '*'},
        options: {'noAuth': true},
      );
      setState(() {
        _data = data['data'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _getWarehouses() async {
    try {
      final data = await ApiService.collections(
        'warehouses',
        options: {'noAuth': true},
      );
      setState(() {
        _warehouses = data['data'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _loadSelectedWarehouse() async {
    String? savedId = await AuthService.storage.read(
      key: 'selected_warehouse_id',
    );
    if (savedId != null) {
      setState(() {
        _selectedWarehouseId = int.tryParse(savedId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _getWarehouses();
    _loadSelectedWarehouse();
  }

  @override
  Widget build(BuildContext context) {
    final banners = (_data['main_banners'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      drawer: DrawerComponent(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_warehouses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value:
                          _warehouses.any(
                            (w) => w['id'] == _selectedWarehouseId,
                          )
                          ? _selectedWarehouseId
                          : null,
                      hint: const Text('Select Warehouse'),
                      items: _warehouses.map<DropdownMenuItem<int>>((
                        warehouse,
                      ) {
                        return DropdownMenuItem<int>(
                          value: warehouse['id'],
                          child: Text(
                            warehouse['name'] ?? 'Unknown Warehouse',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedWarehouseId = newValue;
                        });
                        if (newValue != null) {
                          AuthService.storage.write(
                            key: 'selected_warehouse_id',
                            value: newValue.toString(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            if (banners != null && banners.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 220.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                  ),
                  items: banners.map((banner) {
                    String imageUrl = banner['banner_url'] ?? '';
                    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                      // Remove /api suffix if present to get root domain for images
                      final baseUrl = ApiService.baseUrl.endsWith('/api')
                          ? ApiService.baseUrl.substring(
                              0,
                              ApiService.baseUrl.length - 4,
                            )
                          : ApiService.baseUrl;
                      imageUrl = '$baseUrl$imageUrl';
                    }

                    if (imageUrl.isEmpty) {
                      return const SizedBox();
                    }

                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            if (banners == null || banners.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Icon(Icons.home, size: 100, color: Colors.blue),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _data['product_categories']?.length ?? 0,
                itemBuilder: (context, index) {
                  final category = _data['product_categories'][index];
                  return ProductCategoryComponent(
                    productCategory: category,
                    options: (showAllButton: true),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
