import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/authstate.dart';
import '../providers/firebase_auth.dart';

class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  PhoneAuthNotifier(this.ref) : super(PhoneAuthState(verificationId: ''));

  final Ref ref;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    state = PhoneAuthState(verificationId: '', isLoading: true);
    final auth = ref.read(firebaseAuthProvider);

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        state = PhoneAuthState(verificationId: '');
      },
      verificationFailed: (FirebaseAuthException e) {
        state = PhoneAuthState(verificationId: '', error: e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        state = PhoneAuthState(verificationId: verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        state = PhoneAuthState(verificationId: verificationId);
      },
    );
  }

  Future<void> signInWithSmsCode(String smsCode) async {
    final auth = ref.read(firebaseAuthProvider);
    final credential = PhoneAuthProvider.credential(
      verificationId: state.verificationId,
      smsCode: smsCode,
    );
    await auth.signInWithCredential(credential);
    state = PhoneAuthState(verificationId: '');
  }
}
