enum TransactionStatus {
  success,
  failed,
  pending,
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.merchant,
    required this.description,
  });

  final String id;
  final DateTime date;
  final double amount;
  final TransactionStatus status;
  final String merchant;
  final String description;

  static TransactionStatus _parseStatus(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'SUCCESS':
        return TransactionStatus.success;
      case 'FAILED':
        return TransactionStatus.failed;
      case 'PENDING':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.pending;
    }
  }

  static DateTime _parseDate(String? raw) {
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final date = _parseDate(json['date']?.toString());

    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;

    final status = _parseStatus(json['status']?.toString());
    final merchant = json['merchant']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';

    return TransactionModel(
      id: id,
      date: date,
      amount: amount,
      status: status,
      merchant: merchant,
      description: description,
    );
  }
}

