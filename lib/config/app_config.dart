import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:1337/api';
  static bool isDisableSocialLogin =
      dotenv.env['AUTH_DISABLE_SOCIAL_LOGIN'] == 'true';
  static String iosClientId = dotenv.env['IOS_CLIENT_ID'] ?? '';
}

typedef SupabaseConfig = ({String? supabaseUrl, String? supabaseKey});

typedef FirebaseConfig = ({
  String? appId,
  String? apiKey,
  String? projectId,
  String? authDomain,
  String? databaseURL,
  String? measurementId,
  String? storageBucket,
  String? messagingSenderId,
});

typedef EcommerceConfig = ({
  String? authService,
  FirebaseConfig? firebase,
  SupabaseConfig? supabase,
});

typedef SocialUser = ({
  String? id,
  String? email,
  String? name,
  String? photoURL,
});
