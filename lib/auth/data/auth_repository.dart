import 'package:flutter/foundation.dart';

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
    if (kDebugMode) {
      print('[AuthRepository] login() called');
    }

    // Simulate network latency.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (username == 'user' && password == 'password') {
      if (kDebugMode) {
        print('[AuthRepository] Login successful');
      }
      return 'abc.def.ghi';
    }

    if (kDebugMode) {
      print('[AuthRepository] Login failed - Invalid credentials');
    }
    throw AuthException('Invalid username or password.');
  }
}


/// Using HTTP package (recommended for most use cases)
/// Add to pubspec.yaml: http: ^1.2.0
/*
Future<String> authenticate(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https url'),
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 10)); // Manual timeout

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw AuthException("Failed to login: ${response.statusCode}");
    }
  } on TimeoutException {
    throw AuthException("API timeout");
  } catch (e) {
    throw AuthException(e.toString());
  }
}
*/


/// Using Dio package
/*
class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);


Future<String> authenticate(String username, String password) async {
  try {
    final response = await _dio.post(
      '/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    //as we have json structure
    return response.data['token'];

  } on DioException catch (e) {
    _handleDioError(e);
    rethrow;
  }
}

//categorize and throw specific error messages
void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw AuthException("API timeout");
    }

    if (e.response?.statusCode == 401) {
      throw AuthException("Incorrect username or password.");
    }

    // Default error fallback
    throw AuthException(e.response?.data['message'] ?? "Oops! something went wrong");
  }
}

}
*/

