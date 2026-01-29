import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/common/common_widgets.dart';
import 'package:flutter_project_bfsi/transaction/presentation/transaction_detail_screen.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_cubit.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_state.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadInitialTransactions();
  }

  void _openDetails(TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText('Transactions'),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<AuthCubit>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const CustomText('Logout'),
          ),
        ],
      ),
      body: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: CustomText(state.message)),
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case TransactionInitial():
              return const SizedBox.shrink();
            case TransactionLoading():
              return const Center(child: CircularProgressIndicator());
            case TransactionError(message: final message):
              return _ErrorView(
                message: message,
                onRetry: () => context.read<TransactionCubit>().loadInitialTransactions(),
              );
            case TransactionEmpty():
              return _EmptyView(
                onRefresh: () => context.read<TransactionCubit>().refreshTransactions(),
              );
            case TransactionLoaded(transactions: final items, hasMore: final hasMore):
              return RefreshIndicator(
                onRefresh: () => context.read<TransactionCubit>().refreshTransactions(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () => context.read<TransactionCubit>().loadMoreTransactions(),
                            child: const CustomText('Load more'),
                          ),
                        ),
                      );
                    }

                    final txn = items[index];
                    return _TransactionTile(
                      transaction: txn,
                      currencyText: _currencyFormatter.format(txn.amount),
                      dateText: _dateFormatter.format(txn.date.toLocal()),
                      onTap: () => _openDetails(txn),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currencyText,
    required this.dateText,
    required this.onTap,
  });

  final TransactionModel transaction;
  final String currencyText;
  final String dateText;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    switch (transaction.status) {
      case TransactionStatus.success:
        return Colors.green.shade700;
      case TransactionStatus.failed:
        return Theme.of(context).colorScheme.error;
      case TransactionStatus.pending:
        return Colors.orange.shade700;
    }
  }

  String _statusLabel() {
    switch (transaction.status) {
      case TransactionStatus.success:
        return 'SUCCESS';
      case TransactionStatus.failed:
        return 'FAILED';
      case TransactionStatus.pending:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: CustomText(
        transaction.id,
        fontWeight: FontWeight.w600,
      ),
      subtitle: CustomText(dateText),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomText(
            currencyText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          const SizedBox(height: 4),
          CustomText(
            _statusLabel(),
            color: _statusColor(context),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              message,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const CustomText('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomText(
              'No transactions found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => onRefresh(),
              child: const CustomText('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

