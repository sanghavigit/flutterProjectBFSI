import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';

class TransactionRepositoryException implements Exception {
  TransactionRepositoryException(this.message);
  final String message;
}

class TransactionRepository {
  const TransactionRepository({
    this.assetPath = 'assets/mock/transactions.json',
  });

  final String assetPath;

  Future<List<TransactionModel>> fetchTransactions({
    required int page,
    required int limit,
  }) async {
    if (kDebugMode) {
      print('[TransactionRepository] fetchTransactions() called with page: $page, limit: $limit');
    }

    if (page < 1 || limit < 1) {
      if (kDebugMode) {
        print('[TransactionRepository] Error - Invalid pagination parameters: page=$page, limit=$limit');
      }
      throw TransactionRepositoryException('Invalid pagination parameters.');
    }

    await Future<void>.delayed(const Duration(seconds: 2));

    final rawJson = await _loadAsset();
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
      if (kDebugMode) {
        print('[TransactionRepository] Successfully parsed JSON data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TransactionRepository] Error - Failed to parse transaction data: $e');
      }
      throw TransactionRepositoryException('Failed to parse transaction data.');
    }

    if (decoded is! List) {
      if (kDebugMode) {
        print('[TransactionRepository] Error - Unexpected data format (not a List)');
      }
      throw TransactionRepositoryException('Unexpected transaction data format.');
    }

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList(growable: false);

    if (kDebugMode) {
      print('[TransactionRepository] Total transactions loaded: ${items.length}');
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= items.length) {
      if (kDebugMode) {
        print('[TransactionRepository] No more transactions available (startIndex: $startIndex >= total: ${items.length})');
      }
      return const <TransactionModel>[];
    }

    final endIndex = (startIndex + limit) > items.length
        ? items.length
        : (startIndex + limit);

    final result = items.sublist(startIndex, endIndex);
    if (kDebugMode) {
      print('[TransactionRepository] Returning ${result.length} transactions (from index $startIndex to $endIndex)');
    }
    return result;
  }

  Future<String> _loadAsset() async {
    if (kDebugMode) {
      print('[TransactionRepository] Loading asset from: $assetPath');
    }
    try {
      final data = await rootBundle.loadString(assetPath);
      if (kDebugMode) {
        print('[TransactionRepository] Asset loaded successfully (${data.length} characters)');
      }
      return data;
    } on FlutterError catch (e) {
      if (kDebugMode) {
        print('[TransactionRepository] Error - Asset not found: $assetPath, error: $e');
      }
      throw TransactionRepositoryException(
        'Transaction data not available. Please ensure the asset is registered in pubspec.yaml.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TransactionRepository] Error - Failed to load asset: $e');
      }
      throw TransactionRepositoryException('Failed to load transaction data.');
    }
  }
}




/// Using Dio
/// Add to pubspec.yaml: dio: ^5.4.0
/*

Future<List<TransactionModel>> fetchTransactions({
  required int page,
  required int limit,
  required String token, // You'll need the token from the Login module
}) async {
  try {

    final response = await _dio.get(
      '/transactions',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // Passing the token received from Login
        },
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );


    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } else {
      throw TransactionRepositoryException('Server error: ${response.statusCode}');
    }

  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw TransactionRepositoryException('API timeout');
    }
    if (e.response?.statusCode == 401) {
      throw TransactionRepositoryException('Session expired. Please login again.');
    }
    throw TransactionRepositoryException(e.message ?? 'Failed to fetch transactions');
  } catch (e) {
    throw TransactionRepositoryException('An unexpected error occurred: $e');
  }
}
*/

