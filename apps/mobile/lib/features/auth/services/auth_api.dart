class AuthApi {
  Future<void> requestOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> verifyOtp(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
