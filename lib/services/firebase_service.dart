import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:strapi_ecommerce_flutter/config/app_config.dart';

class FirebaseService {
  static FirebaseConfig? parseFirebaseConfig(Map<String, dynamic>? map) {
    if (map == null) return null;
    return (
      appId: map['appId'] as String?,
      apiKey: map['apiKey'] as String?,
      projectId: map['projectId'] as String?,
      authDomain: map['authDomain'] as String?,
      databaseURL: map['databaseURL'] as String?,
      measurementId: map['measurementId'] as String?,
      storageBucket: map['storageBucket'] as String?,
      messagingSenderId: map['messagingSenderId'] as String?,
    );
  }

  static Future<void> initializeFirebase(FirebaseConfig config) async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        appId: config.appId!,
        apiKey: config.apiKey!,
        projectId: config.projectId!,
        authDomain: config.authDomain!,
        databaseURL: config.databaseURL!,
        measurementId: config.measurementId!,
        storageBucket: config.storageBucket!,
        messagingSenderId: config.messagingSenderId!,
      ),
    );
  }

  static Future<SocialUser?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
        .authenticate();
    if (googleUser == null) return null;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final res = await FirebaseAuth.instance.signInWithCredential(credential);

    return (
      id: res.user?.uid as String,
      email: res.user?.email as String,
      name: res.user?.displayName as String,
      photoURL: res.user?.photoURL as String,
    );
  }

  static Future<SocialUser?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.accessToken == null) return null;

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    final res = await FirebaseAuth.instance.signInWithCredential(
      facebookAuthCredential,
    );

    return (
      id: res.user?.uid as String,
      email: res.user?.email as String,
      name: res.user?.displayName as String,
      photoURL: res.user?.photoURL as String,
    );
  }
}
