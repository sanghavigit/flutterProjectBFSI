import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';

sealed class TransactionState {
  const TransactionState();
}

final class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

final class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

final class TransactionEmpty extends TransactionState {
  const TransactionEmpty();
}

final class TransactionLoaded extends TransactionState {
  const TransactionLoaded({
    required this.transactions,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<TransactionModel> transactions;
  final bool hasMore;
  final bool isLoadingMore;
}

final class TransactionError extends TransactionState {
  const TransactionError({required this.message});
  final String message;
}

