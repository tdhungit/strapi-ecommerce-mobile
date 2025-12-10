import 'package:strapi_ecommerce_flutter/config/app_config.dart';

String imageUrl(dynamic photo) {
  final baseUrl = AppConfig.baseUrl;
  String imageUrl = photo['url'] ?? '';
  if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
    imageUrl = '$baseUrl$imageUrl';
  }
  return imageUrl;
}

String productImageUrl(List<dynamic> photos) {
  final baseUrl = AppConfig.baseUrl;
  String imageUrl = photos.first['url'] ?? '';
  if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
    imageUrl = '$baseUrl$imageUrl';
  }
  return imageUrl;
}
