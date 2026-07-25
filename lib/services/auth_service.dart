import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

/// نتيجة تسجيل الدخول: إما نجاح مباشر أو مطلوب كود 2FA
class LoginResult {
  final bool requires2fa;
  final String? challengeToken;
  final UserModel? user;

  LoginResult.success(this.user)
      : requires2fa = false,
        challengeToken = null;

  LoginResult.needs2fa(this.challengeToken)
      : requires2fa = true,
        user = null;
}

class AuthService {
  final _dio = ApiClient.instance.dio;

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role, // STUDENT or TEACHER
  }) async {
    try {
      final res = await _dio.post(ApiConstants.register, data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      });
      final data = ApiClient.instance.unwrap(res);
      await _saveSession(data);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<LoginResult> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      final data = ApiClient.instance.unwrap(res);

      if (data['requires2fa'] == true) {
        return LoginResult.needs2fa(data['challengeToken']);
      }

      await _saveSession(data);
      return LoginResult.success(UserModel.fromJson(data['user']));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<UserModel> verify2fa({required String challengeToken, required String code}) async {
    try {
      final res = await _dio.post(ApiConstants.verify2fa, data: {
        'challengeToken': challengeToken,
        'code': code,
      });
      final data = ApiClient.instance.unwrap(res);
      await _saveSession(data);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<UserModel> fetchMe() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      final data = ApiClient.instance.unwrap(res);
      final user = UserModel.fromJson(data);
      await SecureStorage.instance.saveRole(data['role'] ?? 'STUDENT');
      return user;
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> logout() async {
    final refreshToken = await SecureStorage.instance.refreshToken;
    try {
      if (refreshToken != null) {
        await _dio.post(ApiConstants.logout, data: {'refreshToken': refreshToken});
      }
    } catch (_) {
      // نمسح الجلسة محليًا حتى لو فشل الطلب
    } finally {
      await SecureStorage.instance.clear();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await SecureStorage.instance.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
    if (data['user']?['role'] != null) {
      await SecureStorage.instance.saveRole(data['user']['role']);
    }
  }
}
