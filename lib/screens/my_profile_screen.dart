import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strapi_ecommerce_flutter/services/auth_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Map<String, dynamic> _user = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.getCurrentUser();
      if (user.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not found')));
        }
        return;
      }
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _user['firstName'] ?? '';
    final lastName = _user['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = _user['email'] ?? 'N/A';
    final phone = _user['phone'] ?? _user['mobile'] ?? 'N/A';
    final leadSource = _user['leadSource'] ?? 'N/A';
    final createdAt = _user['createdAt'];
    final provider = _user['login_provider'] ?? 'Local';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 40,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fullName.isEmpty ? 'No Name' : fullName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Contact Information
                    _buildSectionTitle('Contact Information'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.email_outlined, 'Email', email),
                          const Divider(height: 1),
                          _buildInfoTile(Icons.phone_outlined, 'Phone', phone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account Details
                    _buildSectionTitle('Account Details'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            Icons.source_outlined,
                            'Lead Source',
                            leadSource,
                          ),
                          const Divider(height: 1),
                          _buildInfoTile(
                            Icons.calendar_today_outlined,
                            'Member Since',
                            _formatDate(createdAt),
                          ),
                          const Divider(height: 1),
                          _buildInfoTile(
                            Icons.login_outlined,
                            'Login Provider',
                            provider,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Logout Button (Generic placement, usually strictly handled by settings but good here too)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await AuthService.logout();
                          if (mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.red.shade300),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blueGrey),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
