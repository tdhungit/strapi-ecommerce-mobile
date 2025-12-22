import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class OrderCouponComponent extends StatefulWidget {
  const OrderCouponComponent({super.key, this.onCouponsSelected});

  final Function(List<dynamic> coupons)? onCouponsSelected;

  @override
  State<OrderCouponComponent> createState() => _OrderCouponComponentState();
}

class _OrderCouponComponentState extends State<OrderCouponComponent> {
  List<dynamic> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/customers/coupons',
        'GET',
      );
      setState(() {
        _coupons = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _coupons.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final coupon = _coupons[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  coupon['code'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(coupon['description'] ?? ''),
                trailing: Text(
                  '-\$${coupon['discount_value']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  if (widget.onCouponsSelected != null) {
                    widget.onCouponsSelected!([coupon]);
                  }
                },
              );
            },
          );
  }
}
