import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';
import 'package:strapi_ecommerce_flutter/services/auth_service.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({super.key});

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  List<dynamic> _categories = [];

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _getCategories() async {
    try {
      final data = await ApiService.request(
        '/api/product-categories/extra/tree',
        'GET',
        data: {'status': 'Active'},
        options: {'noAuth': true},
      );
      setState(() {
        _categories = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _buildCategoryItem(dynamic category, {double padding = 16.0}) {
    List<dynamic> children = category['children'] ?? [];

    if (children.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: padding, right: 16.0),
        leading: padding == 16.0 ? const Icon(Icons.category) : null,
        title: Text(category['name']),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/category/${category['documentId']}');
        },
      );
    } else {
      return ExpansionTile(
        tilePadding: EdgeInsets.only(left: padding, right: 16.0),
        leading: padding == 16.0 ? const Icon(Icons.category) : null,
        title: Text(category['name']),
        children: children
            .map((child) => _buildCategoryItem(child, padding: padding + 16.0))
            .toList(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.store, color: Colors.white, size: 64),
                SizedBox(height: 10),
                Text(
                  'Strapi Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          if (_categories.isNotEmpty)
            ..._categories.map((category) => _buildCategoryItem(category)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.red),
            title: const Text('Checkout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/checkout');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my-orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/setting');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
