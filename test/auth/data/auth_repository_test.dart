import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project_bfsi/auth/data/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = const AuthRepository();
    });

    group('login', () {
      test('should return token when credentials are valid', () async {
        // Arrange
        const username = 'user';
        const password = 'password';

        // Act
        final result = await authRepository.login(
          username: username,
          password: password,
        );

        // Assert
        expect(result, isA<String>());
        expect(result, equals('abc.def.ghi'));
      });

      test('should throw AuthException when username is invalid', () async {
        // Arrange
        const username = 'invalid_user';
        const password = 'password';

        // Act & Assert
        expect(
          () => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException when password is invalid', () async {
        // Arrange
        const username = 'user';
        const password = 'wrong_password';

        // Act & Assert
        expect(
          () => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException with correct message for invalid credentials', () async {
        // Arrange
        const username = 'wrong_user';
        const password = 'wrong_password';

        // Act & Assert
        try {
          await authRepository.login(
            username: username,
            password: password,
          );
          fail('Expected AuthException to be thrown');
        } on AuthException catch (e) {
          expect(e.message, equals('Invalid username or password.'));
        }
      });

      test('should throw AuthException when both credentials are empty', () async {
        // Arrange
        const username = '';
        const password = '';

        // Act & Assert
        expect(
          () => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });

  group('AuthException', () {
    test('should store the error message correctly', () {
      // Arrange
      const errorMessage = 'Test error message';

      // Act
      final exception = AuthException(errorMessage);

      // Assert
      expect(exception.message, equals(errorMessage));
    });

    test('should implement Exception interface', () {
      // Arrange & Act
      final exception = AuthException('Error');

      // Assert
      expect(exception, isA<Exception>());
    });
  });
}
