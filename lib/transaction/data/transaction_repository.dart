import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
    print('[TransactionRepository] fetchTransactions() called with page: $page, limit: $limit');
    
    if (page < 1 || limit < 1) {
      print('[TransactionRepository] Error - Invalid pagination parameters: page=$page, limit=$limit');
      throw TransactionRepositoryException('Invalid pagination parameters.');
    }

    await Future<void>.delayed(const Duration(seconds: 2));

    final rawJson = await _loadAsset();
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
      print('[TransactionRepository] Successfully parsed JSON data');
    } catch (e) {
      print('[TransactionRepository] Error - Failed to parse transaction data: $e');
      throw TransactionRepositoryException('Failed to parse transaction data.');
    }

    if (decoded is! List) {
      print('[TransactionRepository] Error - Unexpected data format (not a List)');
      throw TransactionRepositoryException('Unexpected transaction data format.');
    }

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList(growable: false);

    print('[TransactionRepository] Total transactions loaded: ${items.length}');

    final startIndex = (page - 1) * limit;
    if (startIndex >= items.length) {
      print('[TransactionRepository] No more transactions available (startIndex: $startIndex >= total: ${items.length})');
      return const <TransactionModel>[];
    }

    final endIndex = (startIndex + limit) > items.length
        ? items.length
        : (startIndex + limit);

    final result = items.sublist(startIndex, endIndex);
    print('[TransactionRepository] Returning ${result.length} transactions (from index $startIndex to $endIndex)');
    return result;
  }

  Future<String> _loadAsset() async {
    print('[TransactionRepository] Loading asset from: $assetPath');
    try {
      final data = await rootBundle.loadString(assetPath);
      print('[TransactionRepository] Asset loaded successfully (${data.length} characters)');
      return data;
    } on FlutterError catch (e) {
      print('[TransactionRepository] Error - Asset not found: $assetPath, error: $e');
      throw TransactionRepositoryException(
        'Transaction data not available. Please ensure the asset is registered in pubspec.yaml.',
      );
    } catch (e) {
      print('[TransactionRepository] Error - Failed to load asset: $e');
      throw TransactionRepositoryException('Failed to load transaction data.');
    }
  }
}

