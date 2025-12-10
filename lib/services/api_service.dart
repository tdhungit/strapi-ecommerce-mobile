import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:strapi_ecommerce_flutter/config/app_config.dart';

class ApiService {
  static String baseUrl = AppConfig.baseUrl;
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    final token = await storage.read(key: 'token');
    return token;
  }

  static Future<dynamic> request(
    String url,
    String method, {
    Map<String, dynamic>? data,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? options,
  }) async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};

    options ??= {};
    if (options['noAuth'] != true) {
      headers['Authorization'] = 'Token $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    http.Response response;
    switch (method) {
      case 'GET':
        final uri = Uri.parse(
          '$baseUrl$url',
        ).replace(queryParameters: data ?? {});
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          Uri.parse('$baseUrl$url'),
          headers: headers,
          body: jsonEncode(data ?? {}),
        );
        break;
      case 'PUT':
        response = await http.put(
          Uri.parse('$baseUrl$url'),
          headers: headers,
          body: jsonEncode(data ?? {}),
        );
        break;
      case 'DELETE':
        response = await http.delete(
          Uri.parse('$baseUrl$url'),
          headers: headers,
        );
        break;
      default:
        throw Exception('Invalid HTTP method');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to request');
    }

    final responseBody = response.body;
    return jsonDecode(responseBody);
  }

  static Future<dynamic> collections(
    String module, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? options,
  }) async {
    return request('/api/$module', 'GET', data: params, options: options);
  }

  static Future<dynamic> collection(
    String module,
    String id, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? options,
  }) async {
    return request('/api/$module/$id', 'GET', data: params, options: options);
  }

  static Future<dynamic> createCollection(
    String module, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
  }) async {
    return request('/api/$module', 'POST', data: data, options: options);
  }

  static Future<dynamic> updateCollection(
    String module,
    String id, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? options,
  }) async {
    return request('/api/$module/$id', 'PUT', data: data, options: options);
  }

  static Future<dynamic> deleteCollection(
    String module,
    String id, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? options,
  }) async {
    return request(
      '/api/$module/$id',
      'DELETE',
      data: params,
      options: options,
    );
  }
}
