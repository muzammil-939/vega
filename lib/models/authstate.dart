class PhoneAuthState {
  final String verificationId;
  final bool isLoading;
  final String? error;

  PhoneAuthState(
      {required this.verificationId, this.isLoading = false, this.error});
}
