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
    print('[AuthRepository] login() called with username: $username');
    
    // Simulate network latency.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (username == 'user' && password == 'password') {
      print('[AuthRepository] Login successful for user: $username');
      return 'abc.def.ghi';
    }

    print('[AuthRepository] Login failed - Invalid credentials for user: $username');
    throw AuthException('Invalid username or password.');
  }
}



///Using dio if url is available

//
// class AuthRepository {
//   final Dio _dio = Dio();
//
//   Future<String> authenticate(String username, String password) async {
//     try {
//       final response = await _dio.post(
//         'https://api.example.com/login',
//         data: {
//           'username': username,
//           'password': password,
//         },
//       );
//
//       // Dio returns a Map if the response is JSON
//       return response.data['token'];
//     } on DioException catch (e) {
//       // Handle specific status codes or connection issues
//       throw Exception(e.response?.data['message'] ?? 'Login failed');
//     }
//   }
// }

