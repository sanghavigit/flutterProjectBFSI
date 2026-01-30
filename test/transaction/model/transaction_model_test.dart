import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    group('fromJson', () {
      test('should correctly parse valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': '123',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 150.50,
          'status': 'SUCCESS',
          'merchant': 'Amazon',
          'description': 'Online Purchase',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.id, equals('123'));
        expect(transaction.date, equals(DateTime.parse('2024-01-15T10:30:00.000Z')));
        expect(transaction.amount, equals(150.50));
        expect(transaction.status, equals(TransactionStatus.success));
        expect(transaction.merchant, equals('Amazon'));
        expect(transaction.description, equals('Online Purchase'));
      });

      test('should parse numeric id correctly', () {
        // Arrange
        final json = {
          'id': 456,
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.id, equals('456'));
      });

      test('should handle missing id gracefully', () {
        // Arrange
        final json = {
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.id, equals(''));
      });

      test('should handle null values gracefully', () {
        // Arrange
        final json = <String, dynamic>{
          'id': null,
          'date': null,
          'amount': null,
          'status': null,
          'merchant': null,
          'description': null,
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.id, equals(''));
        expect(transaction.date, equals(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
        expect(transaction.amount, equals(0.0));
        expect(transaction.status, equals(TransactionStatus.pending));
        expect(transaction.merchant, equals(''));
        expect(transaction.description, equals(''));
      });

      test('should handle empty JSON gracefully', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.id, equals(''));
        expect(transaction.merchant, equals(''));
        expect(transaction.description, equals(''));
      });

      test('should parse string amount correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': '250.75',
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.amount, equals(250.75));
      });

      test('should handle invalid amount string gracefully', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 'invalid_amount',
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.amount, equals(0.0));
      });

      test('should parse integer amount correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.amount, equals(100.0));
      });
    });

    group('status parsing', () {
      test('should parse SUCCESS status correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.success));
      });

      test('should parse FAILED status correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'FAILED',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.failed));
      });

      test('should parse PENDING status correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'PENDING',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.pending));
      });

      test('should parse lowercase status correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'success',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.success));
      });

      test('should parse mixed case status correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'FaIlEd',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.failed));
      });

      test('should default to pending for unknown status', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-01-15T10:30:00.000Z',
          'amount': 100.0,
          'status': 'UNKNOWN_STATUS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.status, equals(TransactionStatus.pending));
      });
    });

    group('date parsing', () {
      test('should parse valid ISO date correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'date': '2024-06-20T14:45:30.000Z',
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.date.year, equals(2024));
        expect(transaction.date.month, equals(6));
        expect(transaction.date.day, equals(20));
        expect(transaction.date.hour, equals(14));
        expect(transaction.date.minute, equals(45));
      });

      test('should handle invalid date string gracefully', () {
        // Arrange
        final json = {
          'id': '1',
          'date': 'invalid_date',
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.date, equals(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
      });

      test('should handle null date gracefully', () {
        // Arrange
        final json = {
          'id': '1',
          'date': null,
          'amount': 100.0,
          'status': 'SUCCESS',
          'merchant': 'Test',
          'description': 'Test',
        };

        // Act
        final transaction = TransactionModel.fromJson(json);

        // Assert
        expect(transaction.date, equals(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
      });
    });
  });

  group('TransactionStatus', () {
    test('should have three status values', () {
      expect(TransactionStatus.values.length, equals(3));
    });

    test('should contain success status', () {
      expect(TransactionStatus.values, contains(TransactionStatus.success));
    });

    test('should contain failed status', () {
      expect(TransactionStatus.values, contains(TransactionStatus.failed));
    });

    test('should contain pending status', () {
      expect(TransactionStatus.values, contains(TransactionStatus.pending));
    });
  });
}
