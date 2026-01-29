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
    if (page < 1 || limit < 1) {
      throw TransactionRepositoryException('Invalid pagination parameters.');
    }

    await Future<void>.delayed(const Duration(seconds: 2));

    final rawJson = await _loadAsset();
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (_) {
      throw TransactionRepositoryException('Failed to parse transaction data.');
    }

    if (decoded is! List) {
      throw TransactionRepositoryException('Unexpected transaction data format.');
    }

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList(growable: false);

    final startIndex = (page - 1) * limit;
    if (startIndex >= items.length) {
      return const <TransactionModel>[];
    }

    final endIndex = (startIndex + limit) > items.length
        ? items.length
        : (startIndex + limit);

    return items.sublist(startIndex, endIndex);
  }

  Future<String> _loadAsset() async {
    try {
      return await rootBundle.loadString(assetPath);
    } on FlutterError {
      throw TransactionRepositoryException(
        'Transaction data not available. Please ensure the asset is registered in pubspec.yaml.',
      );
    } catch (_) {
      throw TransactionRepositoryException('Failed to load transaction data.');
    }
  }
}

