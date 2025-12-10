import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:strapi_ecommerce_flutter/config/app_config.dart';
import 'package:strapi_ecommerce_flutter/services/firebase_service.dart';
import 'package:strapi_ecommerce_flutter/services/supabase_service.dart';

class AuthService {
  static String baseUrl = AppConfig.baseUrl;
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  static bool _isLoggedIn = false;

  static String _authService = '';

  // Simulate a login process
  static Future<bool> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$baseUrl/api/customers/contact/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['jwt'];
        await storage.write(key: 'token', value: token);
        _isLoggedIn = true;
        return true;
      }

      return false;
    }

    return false;
  }

  // Logout user
  static Future<void> logout() async {
    await storage.delete(key: 'token');
    _isLoggedIn = false;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _isLoggedIn;
  }

  // Set user login
  static void setUserLogin() {
    _isLoggedIn = true;
  }

  static Future<EcommerceConfig> getSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/contact/ecommerce-config'),
    );
    final data = json.decode(response.body);
    return (
      authService: data['authService'] as String?,
      firebase: FirebaseService.parseFirebaseConfig(data['firebase']),
      supabase: SupabaseService.parseSupabaseConfig(data['supabase']),
    );
  }

  static Future<void> initialize(
    String authService, {
    FirebaseConfig? firebaseConfig,
    SupabaseConfig? supabaseConfig,
  }) async {
    _authService = authService;
    if (authService == 'firebase') {
      await FirebaseService.initializeFirebase(firebaseConfig!);
    } else if (authService == 'supabase') {
      await SupabaseService.initializeSupabase(supabaseConfig!);
    }
  }

  static Future<SocialUser?> signInWithGoogle() async {
    if (_authService == 'firebase') {
      return await FirebaseService.signInWithGoogle();
    }

    if (_authService == 'supabase') {
      return await SupabaseService.signInWithGoogle();
    }

    return null;
  }

  static Future<SocialUser?> signInWithFacebook() async {
    if (_authService == 'firebase') {
      return await FirebaseService.signInWithFacebook();
    }

    if (_authService == 'supabase') {
      return await SupabaseService.signInWithFacebook();
    }

    return null;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('User is not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/contact/me'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to request');
    }

    final data = json.decode(response.body);
    return data;
  }
}
