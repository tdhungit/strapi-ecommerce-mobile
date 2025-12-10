import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strapi_ecommerce_flutter/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseConfig? parseSupabaseConfig(Map<String, dynamic>? map) {
    if (map == null) return null;
    return (
      supabaseUrl: map['supabaseUrl'] as String?,
      supabaseKey: map['supabaseKey'] as String?,
    );
  }

  static Future<void> initializeSupabase(SupabaseConfig config) async {
    await Supabase.initialize(
      url: config.supabaseUrl!,
      anonKey: config.supabaseKey!,
    );
  }

  static Future<SocialUser?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
        .authenticate();
    if (googleUser == null) return null;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final res = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return (
      id: res.user?.id as String,
      email: res.user?.email as String,
      name: res.user?.userMetadata!['name'] as String,
      photoURL: res.user?.userMetadata!['avatar_url'] as String,
    );
  }

  static Future<SocialUser?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.accessToken == null) return null;

    if (loginResult.accessToken == null) {
      throw 'No Access Token found.';
    }

    final res = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.facebook,
      idToken: loginResult.accessToken!.tokenString,
    );

    return (
      id: res.user?.id as String,
      email: res.user?.email as String,
      name: res.user?.userMetadata!['name'] as String,
      photoURL: res.user?.userMetadata!['avatar_url'] as String,
    );
  }
}
