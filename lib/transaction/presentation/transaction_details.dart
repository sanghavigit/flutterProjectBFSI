import 'package:flutter/material.dart';
import 'package:flutter_project_bfsi/common/common_widgets.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

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

  IconData _statusIcon() {
    switch (transaction.status) {
      case TransactionStatus.success:
        return Icons.check_circle_outline;
      case TransactionStatus.failed:
        return Icons.error_outline;
      case TransactionStatus.pending:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final amountText = currency.format(transaction.amount);
    final dateText = DateFormat('dd MMM yyyy • hh:mm a').format(
      transaction.date.toLocal(),
    );

    final statusColor = _statusColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const CustomText('Transaction Details'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _statusIcon(),
                          color: statusColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        transaction.merchant,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      CustomText(
                        amountText,
                        fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize ?? 24,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _InfoPill(
                        icon: Icons.receipt_long,
                        text: '${_statusLabel()} • ${transaction.id}',
                        color: statusColor,
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _KeyValueRow(
                        label: 'Date',
                        value: dateText,
                        isEmphasis: true,
                      ),
                      const Divider(height: 24),
                      _KeyValueRow(
                        label: 'Top Up Amount',
                        value: amountText,
                      ),
                      const Divider(height: 24),
                      _KeyValueRow(
                        label: 'Merchant',
                        value: transaction.merchant,
                      ),
                      const Divider(height: 24),
                      _KeyValueRow(
                        label: 'Status',
                        value: _statusLabel(),
                        valueColor: statusColor,
                        isEmphasis: true,
                      ),
                      const Divider(height: 24),
                      _KeyValueRow(
                        label: 'Description',
                        value: transaction.description,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: () {
                            // Placeholder CTA — no business logic here.
                            Navigator.of(context).maybePop();
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const CustomText('Confirmation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          CustomText(
            text,
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isEmphasis = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        );

    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w700,
          color: valueColor ?? Colors.black87,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomText(
            label,
            color: labelStyle?.color,
            fontWeight: labelStyle?.fontWeight,
            fontSize: labelStyle?.fontSize,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomText(
            value,
            color: valueStyle?.color,
            fontWeight: valueStyle?.fontWeight,
            fontSize: valueStyle?.fontSize,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

