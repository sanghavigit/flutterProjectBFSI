import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_project_bfsi/auth/data/auth_repository.dart';
import 'package:flutter_project_bfsi/auth/state/auth_state.dart';
import 'package:flutter_project_bfsi/auth/security/secure_storage_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required SecureStorageService secureStorageService,
  })  : _authRepository = authRepository,
        _secureStorageService = secureStorageService,
        super(const AuthInitial());

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorageService;

  Timer? _inactivityTimer;
  static const Duration _inactivityTimeout = Duration(minutes: 5);

  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (state is AuthAuthenticated) {
      _inactivityTimer = Timer(_inactivityTimeout, _handleInactivityTimeout);
    }
  }

  void _handleInactivityTimeout() {
    if (state is AuthAuthenticated) {
      logout();
    }
  }

  Future<void> checkSession() async {
    final token = await _secureStorageService.readToken();
    if (token == null || token.isEmpty) {
      emit(const AuthInitial());
      return;
    }

    emit(AuthAuthenticated(token: token));
    resetInactivityTimer();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final token = await _authRepository.login(
        username: username,
        password: password,
      );
      await _secureStorageService.saveToken(token);
      emit(AuthAuthenticated(token: token));
      resetInactivityTimer();
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (_) {
      emit(const AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> logout() async {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    await _secureStorageService.clearToken();
    emit(const AuthInitial());
  }

  @override
  Future<void> close() {
    _inactivityTimer?.cancel();
    return super.close();
  }
}

