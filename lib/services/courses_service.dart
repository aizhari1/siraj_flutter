import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/course_model.dart';

class CoursesService {
  final _dio = ApiClient.instance.dio;

  Future<List<CourseModel>> getCourses({
    String? search,
    String? categoryId,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.courses, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        'page': page,
        'limit': 20,
      });
      final data = ApiClient.instance.unwrap(res);
      final list = (data is Map ? data['items'] ?? data['data'] : data) as List? ?? [];
      return list.map((e) => CourseModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<CourseModel> getCourseBySlug(String slug) async {
    try {
      final res = await _dio.get('${ApiConstants.courses}/slug/$slug');
      return CourseModel.fromJson(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<List<CourseModel>> getMyCourses() async {
    try {
      final res = await _dio.get(ApiConstants.myCourses);
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => CourseModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  /// إنشاء كورس جديد (للمدرس)
  Future<CourseModel> createCourse(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(ApiConstants.courses, data: payload);
      return CourseModel.fromJson(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<CourseModel> updateCourse(String id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('${ApiConstants.courses}/$id', data: payload);
      return CourseModel.fromJson(ApiClient.instance.unwrap(res));
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> submitForReview(String id) async {
    try {
      await _dio.patch('${ApiConstants.courses}/$id/submit-for-review');
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  /// أدمن: الكورسات في انتظار المراجعة
  Future<List<CourseModel>> getPendingReview() async {
    try {
      final res = await _dio.get('${ApiConstants.courses}/admin/pending-review');
      final data = ApiClient.instance.unwrap(res) as List;
      return data.map((e) => CourseModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> approveCourse(String id) async {
    try {
      await _dio.patch('${ApiConstants.courses}/$id/approve');
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }

  Future<void> rejectCourse(String id, {String? reason}) async {
    try {
      await _dio.patch('${ApiConstants.courses}/$id/reject', data: {'reason': reason});
    } on DioException catch (e) {
      throw ApiClient.instance.mapError(e);
    }
  }
}
