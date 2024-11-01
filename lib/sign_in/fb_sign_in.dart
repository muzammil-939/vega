import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home.dart';

class SignInMethods {
  static Future<UserCredential?> signInWithFacebook(
      BuildContext context) async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        log(loginResult.accessToken!.tokenString.toString());
        log(loginResult.message.toString());

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        // Once signed in, return the UserCredential
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        // Navigate to the target page after successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return userCredential;
      } else {
        // Handle login failure (e.g., display a message)
        log("Facebook login failed: ${loginResult.status}");
        return null;
      }
    } catch (e) {
      log("Error during Facebook login: $e");
      return null;
    }
  }
}
