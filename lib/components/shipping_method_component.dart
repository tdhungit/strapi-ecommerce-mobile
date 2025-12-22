import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class ShippingMethodComponent extends StatefulWidget {
  const ShippingMethodComponent({super.key, this.onShippingMethodSelected});

  final Function(List<dynamic>, dynamic address)? onShippingMethodSelected;

  @override
  State<ShippingMethodComponent> createState() =>
      _ShippingMethodComponentState();
}

class _ShippingMethodComponentState extends State<ShippingMethodComponent> {
  List<dynamic> _address = [];
  dynamic _selectedAddress;
  List<dynamic> _shippingMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
    _fetchAddress();
    _fetchShippingMethods();
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      final response = await ApiService.request(
        '/api/customers/contact-addresses/default',
        'GET',
      );
      print(response);
      setState(() {
        _selectedAddress = response['address'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _fetchAddress() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/customers/contact-addresses',
        'GET',
      );
      setState(() {
        _address = response;
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
                    const Text(
                      'Selected Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                    'All Addresses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_address.isEmpty) const Text('No addresses found'),
                  ..._address
                      .where((a) => a['id'] != _selectedAddress?['id'])
                      .map(
                        (address) => InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address['name'] ?? 'Address',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${address['address'] ?? ''}, ${address['city'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  const Text(
                    'Shipping Methods',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_shippingMethods.isEmpty)
                    const Text('No shipping methods available'),
                  ..._shippingMethods.map(
                    (method) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            method['name'] ?? 'Method',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
