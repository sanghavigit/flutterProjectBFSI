import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

class AuthRepository {
  const AuthRepository({
    this.assetPath = 'assets/mock/login.json',
  });

  final String assetPath;

  Future<String> login({
    required String username,
    required String password,
  }) async {
    if (kDebugMode) {
      print('[AuthRepository] login() called');
    }

    /// To simulate API delay.
    await Future<void>.delayed(const Duration(seconds: 2));

    final rawJson = await _loadAsset();
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
      if (kDebugMode) {
        print('[AuthRepository] Successfully parsed login mock data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthRepository] Error - Failed to parse login data: $e');
      }
      throw AuthException('Login service unavailable. Please try again.');
    }

    if (decoded is! List) {
      if (kDebugMode) {
        print('[AuthRepository] Error - Unexpected login data format (not a List)');
      }
      throw AuthException('Invalid login configuration.');
    }

    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      final storedUsername = entry['username'] as String?;
      final storedPassword = entry['password'] as String?;
      final token = entry['token'] as String?;
      if (storedUsername == username &&
          storedPassword == password &&
          token != null &&
          token.isNotEmpty) {
        if (kDebugMode) {
          print('[AuthRepository] Login successful');
        }
        return token;
      }
    }

    if (kDebugMode) {
      print('[AuthRepository] Login failed - Invalid credentials');
    }
    throw AuthException('Invalid username or password.');
  }

  Future<String> _loadAsset() async {
    if (kDebugMode) {
      print('[AuthRepository] Loading asset from: $assetPath');
    }
    try {
      final data = await rootBundle.loadString(assetPath);
      if (kDebugMode) {
        print('[AuthRepository] Asset loaded successfully (${data.length} characters)');
      }
      return data;
    } on FlutterError catch (e) {
      if (kDebugMode) {
        print('[AuthRepository] Error - Asset not found: $assetPath, error: $e');
      }
      throw AuthException(
        'Login data not available. Please ensure the asset is registered in pubspec.yaml.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('[AuthRepository] Error - Failed to load asset: $e');
      }
      throw AuthException('Login service unavailable. Please try again.');
    }
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

