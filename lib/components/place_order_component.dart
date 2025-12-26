import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class PlaceOrderComponent extends StatefulWidget {
  const PlaceOrderComponent({
    super.key,
    required this.cart,
    required this.address,
    required this.shippingMethod,
    required this.coupons,
    this.onPaymentMethodSelected,
  });

  final dynamic cart;
  final dynamic address;
  final dynamic shippingMethod;
  final List<dynamic> coupons;
  final Function(dynamic paymentMethod)? onPaymentMethodSelected;

  @override
  State<PlaceOrderComponent> createState() => _PlaceOrderComponentState();
}

class _PlaceOrderComponentState extends State<PlaceOrderComponent> {
  bool _isLoading = true;
  List<dynamic> _paymentMethods = [];
  dynamic _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/public/payment-methods',
        'GET',
      );
      setState(() {
        _paymentMethods = response;
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
        : SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_paymentMethods.isEmpty)
                    const Text('No payment methods available'),
                  RadioGroup<dynamic>(
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    child: Column(
                      children: _paymentMethods
                          .map(
                            (method) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = method;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedPaymentMethod == method
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: _selectedPaymentMethod == method
                                        ? 2
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _selectedPaymentMethod == method
                                      ? Colors.blue.withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Radio<dynamic>(
                                      value: method,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedPaymentMethod = value;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.payment_outlined,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            method['name'] ?? 'Payment Method',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  _selectedPaymentMethod ==
                                                      method
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                          if (method['description'] != null &&
                                              method['description']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                method['description'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_paymentMethods.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedPaymentMethod != null
                            ? () {
                                widget.onPaymentMethodSelected?.call(
                                  _selectedPaymentMethod,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: const Text(
                          'Confirm Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
  }
}
