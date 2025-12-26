import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/components/customer_address_component.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class ShippingMethodComponent extends StatefulWidget {
  const ShippingMethodComponent({super.key, this.onShippingMethodSelected});

  final Function(dynamic method, dynamic address)? onShippingMethodSelected;

  @override
  State<ShippingMethodComponent> createState() =>
      _ShippingMethodComponentState();
}

class _ShippingMethodComponentState extends State<ShippingMethodComponent> {
  bool _isLoading = true;
  dynamic _selectedAddress;
  dynamic _selectedShippingMethod;
  List<dynamic> _shippingMethods = [];

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();

    _fetchShippingMethods();
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      final response = await ApiService.request(
        '/api/customers/contact-addresses/default',
        'GET',
      );
      setState(() {
        _selectedAddress = response['address'];
        widget.onShippingMethodSelected?.call(
          _selectedShippingMethod,
          _selectedAddress,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _fetchShippingMethods() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/public/shipping-methods',
        'GET',
      );
      setState(() {
        _shippingMethods = response;
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
                  if (_selectedAddress != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Address',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: _openAddressModal,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedAddress['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_selectedAddress['is_default'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedAddress['address'] ?? ''}, ${_selectedAddress['city'] ?? ''}, ${_selectedAddress['state'] ?? ''} ${_selectedAddress['zipcode'] ?? ''}, ${_selectedAddress['country'] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[800],
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress['phone'] ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Shipping Methods',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_shippingMethods.isEmpty)
                    const Text('No shipping methods available'),
                  RadioGroup<dynamic>(
                    groupValue: _selectedShippingMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedShippingMethod = value;
                      });
                    },
                    child: Column(
                      children: _shippingMethods
                          .map(
                            (method) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedShippingMethod = method;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedShippingMethod == method
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: _selectedShippingMethod == method
                                        ? 2
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _selectedShippingMethod == method
                                      ? Colors.blue.withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Radio<dynamic>(
                                      value: method,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedShippingMethod = value;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.local_shipping_outlined,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            method['name'] ?? 'Method',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  _selectedShippingMethod ==
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
                  if (_shippingMethods.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedShippingMethod != null
                            ? () {
                                widget.onShippingMethodSelected?.call(
                                  _selectedShippingMethod,
                                  _selectedAddress,
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
                          'Confirm Shipping Method',
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

  void _openAddressModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomerAddressComponent(
                onAddressSelected: (allAddresses, selected) {
                  setState(() {
                    _selectedAddress = selected;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
