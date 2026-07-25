import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;

  const AuthState({this.status = AuthStatus.unknown, this.user});

  AuthState copyWith({AuthStatus? status, UserModel? user}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _bootstrap();
  }

  final _authService = AuthService();

  Future<void> _bootstrap() async {
    final token = await SecureStorage.instance.accessToken;
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _authService.fetchMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await SecureStorage.instance.clear();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<LoginResult> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    if (!result.requires2fa) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    }
    return result;
  }

  Future<void> verify2fa(String challengeToken, String code) async {
    final user = await _authService.verify2fa(challengeToken: challengeToken, code: code);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final user = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _authService.fetchMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
