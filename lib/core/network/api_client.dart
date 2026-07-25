import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// نتيجة موحّدة تُستخدم في كل الـ Repositories
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}',
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.instance.accessToken;
          if (token != null && !options.path.contains('/auth/')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // لو التوكن منتهي، نحاول نجدده مرة واحدة ثم نعيد الطلب
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/refresh')) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final clonedRequest = await _retry(error.requestOptions);
              return handler.resolve(clonedRequest);
            }
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  Dio get dio => _dio;

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await SecureStorage.instance.refreshToken;
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}'),
      ).post(ApiConstants.refreshToken, data: {'refreshToken': refreshToken});

      final data = response.data['data'];
      await SecureStorage.instance.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      return true;
    } catch (_) {
      await SecureStorage.instance.clear();
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await SecureStorage.instance.accessToken;
    final options = Options(method: requestOptions.method, headers: {
      ...requestOptions.headers,
      'Authorization': 'Bearer $token',
    });
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// يحوّل أي استجابة API لصيغة موحدة { message, data }
  dynamic unwrap(Response response) {
    if (response.data is Map && response.data['data'] != null) {
      return response.data['data'];
    }
    return response.data;
  }

  ApiException mapError(DioException e) {
    final status = e.response?.statusCode;
    String message = 'حصل خطأ غير متوقع، حاول تاني';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      message = 'مفيش اتصال بالسيرفر. اتأكد من الإنترنت وحاول تاني';
    } else if (e.response?.data is Map && e.response?.data['message'] != null) {
      final m = e.response?.data['message'];
      message = m is List ? m.join('\n') : m.toString();
    }
    return ApiException(message, statusCode: status);
  }
}
