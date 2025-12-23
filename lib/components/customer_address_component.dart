import 'package:flutter/material.dart';
import 'package:strapi_ecommerce_flutter/services/api_service.dart';

class CustomerAddressComponent extends StatefulWidget {
  const CustomerAddressComponent({super.key, this.onAddressSelected});

  final Function(List<dynamic>, dynamic address)? onAddressSelected;

  @override
  State<CustomerAddressComponent> createState() =>
      _CustomerAddressComponentState();
}

class _CustomerAddressComponentState extends State<CustomerAddressComponent> {
  List<dynamic> _address = [];
  dynamic _selectedAddress;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _countries = [];
  List<dynamic> _states = [];
  List<dynamic> _cities = [];

  // Controllers for add address form
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddress();
    _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/address/countries',
        'GET',
        options: {'noAuth': true},
      );
      setState(() {
        _countries = response;
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

  Future<void> _fetchStates(String country) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/address/countries/$country/states',
        'GET',
        options: {'noAuth': true},
      );
      setState(() {
        _states = response;
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

  Future<void> _fetchCities(String state) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        '/api/address/states/$state/cities',
        'GET',
        options: {'noAuth': true},
      );
      setState(() {
        _cities = response;
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

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context); // Close modal
    setState(() => _isLoading = true);

    try {
      await ApiService.request(
        '/api/customers/contact-addresses',
        'POST',
        data: {
          'fullName': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postalCode': _zipCodeController.text,
          'country': _countryController.text,
        },
      );

      // Clear controllers
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipCodeController.clear();
      _countryController.clear();
      _phoneController.clear();

      await _fetchAddress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address added successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showAddAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(labelText: 'Country'),
                    isExpanded: true,
                    items: _countries.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c['name'] ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val != null) {
                        _countryController.text = val['name'];
                        _stateController.clear();
                        _cityController.clear();
                        setModalState(() {
                          _states = [];
                          _cities = [];
                        });
                        await _fetchStates(val['name']);
                        setModalState(() {});
                      }
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(labelText: 'State'),
                    isExpanded: true,
                    items: _states.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s['name'] ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _states.isEmpty
                        ? null
                        : (val) async {
                            if (val != null) {
                              _stateController.text = val['name'];
                              _cityController.clear();
                              setModalState(() {
                                _cities = [];
                              });
                              await _fetchCities(val['name']);
                              setModalState(() {});
                            }
                          },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(labelText: 'City'),
                    isExpanded: true,
                    items: _cities.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c['name'] ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _cities.isEmpty
                        ? null
                        : (val) {
                            if (val != null) {
                              _cityController.text = val['name'];
                            }
                          },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(labelText: 'Zip Code'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    child: const Text('Save Address'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
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
                        color: Colors.blue.withValues(alpha: 0.05),
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
                    const SizedBox(height: 8),
                  ],

                  // Add New Address Button
                  OutlinedButton.icon(
                    onPressed: _showAddAddressForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_address.isEmpty)
                    const Center(
                      child: Text(
                        'No addresses found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

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
                  ElevatedButton(
                    onPressed: () {
                      if (widget.onAddressSelected != null) {
                        widget.onAddressSelected!(_address, _selectedAddress);
                      }
                    },
                    child: const Text('Select Address'),
                  ),
                ],
              ),
            ),
          );
  }
}
