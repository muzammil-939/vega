import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vega/providers/loader.dart';

import '../models/authstate.dart';
import '../providers/firebase_auth.dart';

class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  PhoneAuthNotifier() : super(PhoneAuthState(verificationId: ''));

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the Firebase token is stored in shared preferences
    if (!prefs.containsKey('firebaseToken')) {
      print('No Firebase token found. tryAutoLogin is set to false.');
      return false;
    }

    // Retrieve the Firebase token
    String? firebaseToken = prefs.getString('firebaseToken');

    // If the token exists, save it to the model and return true
    print('Firebase token found: $firebaseToken');

    // Assuming you have a way to update your model's state with the Firebase token
    state = state.copyWith(firebaseToken: firebaseToken);

    return true;
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, WidgetRef ref, Function verifyotp) async {
    final auth = ref.read(firebaseAuthProvider);
    var loader = ref.read(loadingProvider.notifier);
    loader.state = true;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        loader.state = false;
        await auth.signInWithCredential(credential);
        state = PhoneAuthState(verificationId: '');
      },
      verificationFailed: (FirebaseAuthException e) {
        loader.state = false;
        state = PhoneAuthState(verificationId: '', error: e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        loader.state = false;
        state = PhoneAuthState(verificationId: verificationId);
        verifyotp();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        loader.state = false;
        state = PhoneAuthState(verificationId: verificationId);
      },
    );
  }

  Future<void> signInWithPhoneNumber(String smsCode, WidgetRef ref) async {
    final authState = ref.watch(firebaseAuthProvider);
    final loadingState = ref.watch(loadingProvider.notifier);
    print("entered in phone verification");

    try {
      loadingState.state = true;

      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: state.verificationId, smsCode: smsCode);

      await authState.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          print("phone verification Successful");

          // Generate a custom UID
          String customUid =
              "#${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}";
          String? firebaseToken = await value.user?.getIdToken();
          // Get the database
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firebaseToken', firebaseToken!);
          final databaseReference =
              FirebaseDatabase.instance.ref("users/${value.user!.uid}");

          state = state.copyWith(firebaseToken: firebaseToken);

          try {
            // Store user data with the custom UID
            await databaseReference.set({
              "uid": customUid,
              "phoneNumber": value.user!.phoneNumber,
              "createdAt": DateTime.now().toIso8601String(),
              // Add other user details if needed
            });
            print("User data successfully stored in Firebase.");
          } catch (dbError) {
            print("Failed to store data: $dbError");
          }
        }
      });

      loadingState.state = false;
    } catch (e) {
      loadingState.state = false;
      print("Error during phone verification: $e");
    } finally {
      loadingState.state = false;
    }
  }

  Future<String> generateUniqueUid() async {
    final databaseReference = FirebaseDatabase.instance.ref("userUIDs");
    Random random = Random();
    String uniqueUid;

    while (true) {
      // Generate a random 6-digit number
      int randomNumber =
          100000 + random.nextInt(900000); // Range: 100000 to 999999
      uniqueUid = "$randomNumber#";

      // Check if this UID already exists in the database
      final snapshot = await databaseReference.child(uniqueUid).get();
      if (!snapshot.exists) {
        // If the UID is unique, store it in the database
        await databaseReference.child(uniqueUid).set(true);
        break; // Exit the loop when a unique UID is found
      }
    }

    return uniqueUid;
  }

  // Future<void> signInWithSmsCode(String smsCode) async {
  //   final auth = ref.read(firebaseAuthProvider);
  //   final credential = PhoneAuthProvider.credential(
  //     verificationId: state.verificationId,
  //     smsCode: smsCode,
  //   );
  //   await auth.signInWithCredential(credential);
  // }
}
