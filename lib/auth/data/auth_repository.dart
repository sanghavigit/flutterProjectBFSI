class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

class AuthRepository {
  const AuthRepository();

  Future<String> login({
    required String username,
    required String password,
  }) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (username == 'user' && password == 'password') {
      return 'abc.def.ghi';
    }

    throw AuthException('Invalid username or password.');
  }
}

