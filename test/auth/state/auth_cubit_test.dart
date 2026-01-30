import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project_bfsi/auth/data/auth_repository.dart';
import 'package:flutter_project_bfsi/auth/security/secure_storage_service.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/auth/state/auth_state.dart';
import '../../mocks/mock_repositories.dart';

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorageService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorageService = MockSecureStorageService();
    authCubit = AuthCubit(
      authRepository: mockAuthRepository,
      secureStorageService: mockSecureStorageService,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state should be AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('checkSession', () {
      blocTest<AuthCubit, AuthState>(
        'should emit AuthAuthenticated when token exists in storage',
        setUp: () {
          when(() => mockSecureStorageService.readToken())
              .thenAnswer((_) async => 'existing_token');
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.checkSession(),
        expect: () => [
          isA<AuthAuthenticated>().having(
            (state) => state.token,
            'token',
            'existing_token',
          ),
        ],
        verify: (_) {
          verify(() => mockSecureStorageService.readToken()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit AuthInitial when no token exists in storage',
        setUp: () {
          when(() => mockSecureStorageService.readToken())
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.checkSession(),
        expect: () => [isA<AuthInitial>()],
        verify: (_) {
          verify(() => mockSecureStorageService.readToken()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit AuthInitial when token is empty string',
        setUp: () {
          when(() => mockSecureStorageService.readToken())
              .thenAnswer((_) async => '');
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.checkSession(),
        expect: () => [isA<AuthInitial>()],
      );
    });

    group('login', () {
      const testUsername = 'testuser';
      const testPassword = 'testpassword';
      const testToken = 'test_token_123';

      blocTest<AuthCubit, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when login succeeds',
        setUp: () {
          when(() => mockAuthRepository.login(
                username: testUsername,
                password: testPassword,
              )).thenAnswer((_) async => testToken);
          when(() => mockSecureStorageService.saveToken(testToken))
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.login(
          username: testUsername,
          password: testPassword,
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.token,
            'token',
            testToken,
          ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.login(
                username: testUsername,
                password: testPassword,
              )).called(1);
          verify(() => mockSecureStorageService.saveToken(testToken)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails with AuthException',
        setUp: () {
          when(() => mockAuthRepository.login(
                username: testUsername,
                password: testPassword,
              )).thenThrow(AuthException('Invalid credentials'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.login(
          username: testUsername,
          password: testPassword,
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'message',
            'Invalid credentials',
          ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.login(
                username: testUsername,
                password: testPassword,
              )).called(1);
          verifyNever(() => mockSecureStorageService.saveToken(any()));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit [AuthLoading, AuthError] with generic message when unexpected error occurs',
        setUp: () {
          when(() => mockAuthRepository.login(
                username: testUsername,
                password: testPassword,
              )).thenThrow(Exception('Network error'));
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.login(
          username: testUsername,
          password: testPassword,
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'message',
            'Something went wrong. Please try again.',
          ),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'should emit AuthInitial and clear token on logout',
        setUp: () {
          when(() => mockSecureStorageService.clearToken())
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.logout(),
        expect: () => [isA<AuthInitial>()],
        verify: (_) {
          verify(() => mockSecureStorageService.clearToken()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should clear session even when starting from authenticated state',
        seed: () => const AuthAuthenticated(token: 'existing_token'),
        setUp: () {
          when(() => mockSecureStorageService.clearToken())
              .thenAnswer((_) async {});
        },
        build: () => AuthCubit(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        ),
        act: (cubit) => cubit.logout(),
        expect: () => [isA<AuthInitial>()],
      );
    });
  });
}
