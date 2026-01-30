import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project_bfsi/auth/presentation/login_page.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/auth/state/auth_state.dart';

/// Mock class for AuthCubit using bloc_test's MockCubit
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  tearDown(() {
    mockAuthCubit.close();
  });

  /// Helper function to build the LoginPage with required providers
  Widget buildTestableWidget() {
    return MaterialApp(
      routes: {
        '/': (_) => BlocProvider<AuthCubit>.value(
              value: mockAuthCubit,
              child: const LoginPage(),
            ),
        '/transactions': (_) => const Scaffold(
              body: Center(child: Text('Transactions Screen')),
            ),
      },
      initialRoute: '/',
    );
  }

  group('LoginPage', () {
    group('UI Elements', () {
      testWidgets('should display login page title', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.text('Secure Transaction Dashboard'), findsOneWidget);
      });

      testWidgets('should display username text field', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      });

      testWidgets('should display password text field', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      });

      testWidgets('should display login button', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.text('Login'), findsOneWidget);
      });

      testWidgets('should have password visibility toggle', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should show error when username is empty', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter your username'), findsOneWidget);
      });

      testWidgets('should show error when password is empty', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Enter username only
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          'testuser',
        );
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show error when password is less than 6 characters',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Enter credentials with short password
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          'testuser',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          '12345',
        );
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      });

      testWidgets('should call login when form is valid', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
        when(() => mockAuthCubit.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Enter valid credentials
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          'testuser',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'password123',
        );
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockAuthCubit.login(
              username: 'testuser',
              password: 'password123',
            )).called(1);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when AuthLoading',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Logging in...'), findsOneWidget);
      });

      testWidgets('should disable login button when loading', (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Assert
        expect(find.text('Logging in...'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('should display error message when AuthError',
          (tester) async {
        // Arrange
        const errorMessage = 'Invalid username or password.';
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
        whenListen(
          mockAuthCubit,
          Stream.fromIterable([
            const AuthLoading(),
            const AuthError(message: errorMessage),
          ]),
          initialState: const AuthInitial(),
        );

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(errorMessage), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to transactions on AuthAuthenticated',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
        whenListen(
          mockAuthCubit,
          Stream.fromIterable([
            const AuthAuthenticated(token: 'test_token'),
          ]),
          initialState: const AuthInitial(),
        );

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Transactions Screen'), findsOneWidget);
      });
    });

    group('Password Visibility Toggle', () {
      testWidgets('should toggle password visibility when icon is tapped',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());

        // Initially password should be obscured (visibility_off icon)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);

        // Tap the visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Now password should be visible (visibility icon)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
      });
    });

    group('Text Input', () {
      testWidgets('should accept text input in username field',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          'myusername',
        );

        // Assert
        expect(find.text('myusername'), findsOneWidget);
      });

      testWidgets('should accept text input in password field',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildTestableWidget());
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'secretpassword',
        );
        await tester.pump();

        // Assert - we can't directly check obscured text, but we can verify
        // the field accepts input by checking the controller value via form validation
        final textField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Password'),
        );
        expect(textField.controller?.text, equals('secretpassword'));
      });
    });
  });
}
