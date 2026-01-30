import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project_bfsi/auth/security/secure_storage_service.dart';
import '../../mocks/mock_repositories.dart';

void main() {
  late SecureStorageService secureStorageService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    group('saveToken', () {
      test('should call write with correct key and value', () async {
        // Arrange
        const token = 'test_token_123';
        when(() => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        // Act
        await secureStorageService.saveToken(token);

        // Assert
        verify(() => mockStorage.write(
              key: 'auth_token',
              value: token,
            )).called(1);
      });

      test('should save empty token', () async {
        // Arrange
        const token = '';
        when(() => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        // Act
        await secureStorageService.saveToken(token);

        // Assert
        verify(() => mockStorage.write(
              key: 'auth_token',
              value: token,
            )).called(1);
      });
    });

    group('readToken', () {
      test('should return token when it exists', () async {
        // Arrange
        const expectedToken = 'stored_token_456';
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => expectedToken);

        // Act
        final result = await secureStorageService.readToken();

        // Assert
        expect(result, equals(expectedToken));
        verify(() => mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);

        // Act
        final result = await secureStorageService.readToken();

        // Assert
        expect(result, isNull);
      });

      test('should return empty string when token is empty', () async {
        // Arrange
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => '');

        // Act
        final result = await secureStorageService.readToken();

        // Assert
        expect(result, equals(''));
      });
    });

    group('clearToken', () {
      test('should call delete with correct key', () async {
        // Arrange
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        // Act
        await secureStorageService.clearToken();

        // Assert
        verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      });
    });

    group('Token lifecycle', () {
      test('should complete full token lifecycle: save, read, clear', () async {
        // Arrange
        const token = 'lifecycle_token';
        String? storedValue;

        when(() => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((invocation) async {
          storedValue = invocation.namedArguments[const Symbol('value')];
        });

        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => storedValue);

        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {
          storedValue = null;
        });

        // Act & Assert - Save
        await secureStorageService.saveToken(token);
        verify(() => mockStorage.write(key: 'auth_token', value: token))
            .called(1);

        // Act & Assert - Read
        final readResult = await secureStorageService.readToken();
        expect(readResult, equals(token));

        // Act & Assert - Clear
        await secureStorageService.clearToken();
        verify(() => mockStorage.delete(key: 'auth_token')).called(1);

        // Verify token is cleared
        final clearedResult = await secureStorageService.readToken();
        expect(clearedResult, isNull);
      });
    });
  });
}
