import 'package:flutter/material.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:flutter_project_bfsi/transaction/presentation/transaction_details.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return TransactionDetails(transaction: transaction);
  }
}

