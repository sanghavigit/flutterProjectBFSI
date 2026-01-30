import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project_bfsi/auth/data/auth_repository.dart';
import 'package:flutter_project_bfsi/auth/security/secure_storage_service.dart';
import 'package:flutter_project_bfsi/transaction/data/transaction_repository.dart';

/// Mock class for AuthRepository
/// Used to simulate authentication API calls in tests
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock class for TransactionRepository
/// Used to simulate transaction data fetching in tests
class MockTransactionRepository extends Mock implements TransactionRepository {}

/// Mock class for SecureStorageService
/// Used to simulate secure storage operations in tests
class MockSecureStorageService extends Mock implements SecureStorageService {}

/// Mock class for FlutterSecureStorage
/// Used to test SecureStorageService directly
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
