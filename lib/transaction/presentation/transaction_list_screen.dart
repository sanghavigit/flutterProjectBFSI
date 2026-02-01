import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/common/common_widgets.dart';
import 'package:flutter_project_bfsi/transaction/presentation/transaction_details.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_cubit.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_state.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/colors.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _currencyFormatter =
      NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadInitialTransactions();
  }

  void _openDetails(TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetails(transaction: transaction),
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          'Log out',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        content: const CustomText(
          'Are you sure you want to log out?',
        ),
        actions: [
          CustomButton(
            text: 'No',
            type: ButtonType.text,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CustomButton(
            text: 'Yes',
            type: ButtonType.text,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !context.mounted) return;
    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepPurple,
        centerTitle: true,
        title: const CustomText('Transactions', fontSize: 20, fontWeight: FontWeight.w700, color: cream,),
        actions: [
          IconButton(
            onPressed: _onLogoutPressed,
            icon: const Icon(
              Icons.logout_rounded,
              color: cream,
            ),
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
              return const _TransactionListShimmer();
            case TransactionError(message: final message):
              return _ErrorView(
                message: message,
                onRetry: () =>
                    context.read<TransactionCubit>().loadInitialTransactions(),
              );
            case TransactionEmpty():
              return _EmptyView(
                onRefresh: () =>
                    context.read<TransactionCubit>().refreshTransactions(),
              );
            case TransactionLoaded(
                transactions: final items,
                hasMore: final hasMore,
                isLoadingMore: final isLoadingMore,
              ):
              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<TransactionCubit>().refreshTransactions(),
                  child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        deepPurple,
                        lightPurple
                      ]
                    )
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16.0),
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length + (hasMore || isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        if (isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: deepPurple,
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CustomButton(
                              text: 'Load more',
                              textColor: deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              borderRadius: 32.0,
                              height: 50,
                              width: 100,
                              onPressed: () => context
                                  .read<TransactionCubit>()
                                  .loadMoreTransactions(),
                              type: ButtonType.outlined,
                              borderColor: deepPurple,
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
                ),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      elevation: 0.5,
      color: tileColor,
      child: ListTile(
        onTap: onTap,
        title: CustomText(
          transaction.id,
          fontWeight: FontWeight.w600,
        ),
        subtitle: CustomText(dateText),
        isThreeLine: false,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              currencyText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            Space.vertical(4),
            CustomText(
              _statusLabel(),
              color: _statusColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListShimmer extends StatelessWidget {
  const _TransactionListShimmer();

  static const int _shimmerTileCount = 8;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tileColor, lightPurple],
          ),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            physics: const ClampingScrollPhysics(),
            itemCount: _shimmerTileCount,
            itemBuilder: (context, index) => const _ShimmerTile(),
          ),
        ),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    const placeholderColor = Color(0xFFE0E0E0);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      elevation: 0.5,
      color: tileColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Container(
          height: 16,
          width: 160,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Space.vertical(8),
            Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 14,
              width: 56,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Space.vertical(8),
            Container(
              height: 12,
              width: 52,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
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
            Space.vertical(16),
            CustomButton(
              text: 'Retry',
              onPressed: onRetry,
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
            Space.vertical(12),
            CustomButton(
              text: 'Refresh',
              onPressed: () => onRefresh(),
              type: ButtonType.outlined,
            ),
          ],
        ),
      ),
    );
  }
}
