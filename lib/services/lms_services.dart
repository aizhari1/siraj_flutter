import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/exam_model.dart';
import '../models/misc_models.dart';
import '../models/user_model.dart';

class EnrollmentsService {
  final _dio = ApiClient.instance.dio;

  Future<void> enrollFree(String courseId) async {
    try {
      await _dio.post(ApiConstants.enrollFree, data: {'courseId': courseId});
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<List<EnrollmentModel>> myCourses() async {
    try {
      final res = await _dio.get(ApiConstants.myEnrollments);
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => EnrollmentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}

class ExamsService {
  final _dio = ApiClient.instance.dio;

  Future<ExamModel> getExam(String id) async {
    try {
      final res = await _dio.get('${ApiConstants.exams}/$id');
      return ExamModel.fromJson(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}

class CertificatesService {
  final _dio = ApiClient.instance.dio;

  Future<List<CertificateModel>> myCertificates() async {
    try {
      final res = await _dio.get(ApiConstants.myCertificates);
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => CertificateModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}

class PaymentsService {
  final _dio = ApiClient.instance.dio;

  /// يرجع رابط Stripe Checkout المستضاف عشان يتفتح في WebView
  Future<String> createCheckoutUrl(String courseId) async {
    try {
      final res = await _dio.post(ApiConstants.checkout, data: {'courseId': courseId});
      final data = ApiClient.instance.unwrap(res);
      return data['checkoutUrl'] ?? data['url'];
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<List<OrderModel>> myOrders() async {
    try {
      final res = await _dio.get(ApiConstants.myOrders);
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  /// أرباح المدرس
  Future<Map<String, dynamic>> myEarnings() async {
    try {
      final res = await _dio.get(ApiConstants.myEarnings);
      return Map<String, dynamic>.from(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}

class UsersService {
  final _dio = ApiClient.instance.dio;

  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch(ApiConstants.me, data: payload);
      return UserModel.fromJson(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  /// أدمن: كل المستخدمين
  Future<List<UserModel>> getAllUsers({String? role}) async {
    try {
      final res = await _dio.get(ApiConstants.users, queryParameters: {
        if (role != null) 'role': role,
      });
      final data = ApiClient.instance.unwrap(res);
      final list = (data is Map ? data['items'] ?? data['data'] : data) as List? ?? [];
      return list.map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> updateUserStatus(String id, bool isActive) async {
    try {
      await _dio.patch('${ApiConstants.users}/$id/status', data: {'isActive': isActive});
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> updateUserRole(String id, String role) async {
    try {
      await _dio.patch('${ApiConstants.users}/$id/role', data: {'role': role});
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}

class NotificationsService {
  final _dio = ApiClient.instance.dio;

  Future<List<NotificationModel>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.notifications);
      final data = ApiClient.instance.unwrap(res);
      final list = (data is Map ? data['items'] ?? data['data'] : data) as List? ?? [];
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final res = await _dio.get('${ApiConstants.notifications}/unread-count');
      final data = ApiClient.instance.unwrap(res);
      return data is int ? data : (data['count'] ?? 0);
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}
