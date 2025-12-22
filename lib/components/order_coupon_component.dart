import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class OrderCouponComponent extends StatefulWidget {
  const OrderCouponComponent({
    super.key,
    this.onCouponsSelected,
    this.initialCoupons = const [],
  });

  final Function(List<dynamic> coupons)? onCouponsSelected;
  final List<dynamic> initialCoupons;

  @override
  State<OrderCouponComponent> createState() => _OrderCouponComponentState();
}

class _OrderCouponComponentState extends State<OrderCouponComponent> {
  List<dynamic> _coupons = [];
  bool _isLoading = true;
  final Map<String, dynamic> _selectedCouponsByType = {};

  @override
  void initState() {
    super.initState();
    for (var coupon in widget.initialCoupons) {
      if (coupon['coupon_type'] != null) {
        _selectedCouponsByType[coupon['coupon_type']] = coupon;
      }
    }
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

  Map<String, List<dynamic>> get _groupedCoupons {
    final grouped = <String, List<dynamic>>{};
    for (var coupon in _coupons) {
      final type = coupon['coupon_type'] ?? 'General';
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(coupon);
    }
    return grouped;
  }

  void _toggleCoupon(dynamic coupon) {
    setState(() {
      final type = coupon['coupon_type'] ?? 'General';
      // If tapping the already selected coupon, deselect it (optional, but good UX)
      if (_selectedCouponsByType[type]?['id'] == coupon['id']) {
        _selectedCouponsByType.remove(type);
      } else {
        // Select new coupon for this type (replacing old one)
        _selectedCouponsByType[type] = coupon;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final grouped = _groupedCoupons;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.keys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final type = grouped.keys.elementAt(index);
              final coupons = grouped[type]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...coupons.map((coupon) {
                    final isSelected =
                        _selectedCouponsByType[type]?['id'] == coupon['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _toggleCoupon(coupon),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.05)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: coupon['id'],
                                groupValue: _selectedCouponsByType[type]?['id'],
                                onChanged: (val) => _toggleCoupon(coupon),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coupon['code'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (coupon['description'] != null)
                                      Text(
                                        coupon['description'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  coupon['discount_type'] == 'percentage'
                                      ? '${coupon['discount_value']}%'
                                      : '-\$${coupon['discount_value']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onCouponsSelected != null) {
                    widget.onCouponsSelected!(
                      _selectedCouponsByType.values.toList(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Coupons (${_selectedCouponsByType.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
