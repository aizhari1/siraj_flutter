/// عدّل الـ Base URL على سيرفرك بعد الديبلوي (Render/غيره)
/// - أثناء التطوير على محاكي أندرويد استخدم: http://10.0.2.2:3000
/// - على جهاز حقيقي على نفس الشبكة: http://<PC_LOCAL_IP>:3000
/// - بعد رفع الباك ايند: https://your-api-domain.onrender.com
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lms-platform1.pxxl.run',
  );

  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verify2fa = '/auth/login/2fa-verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String me = '/users/me';
  static const String users = '/users';

  // Courses
  static const String courses = '/courses';
  static const String myCourses = '/courses/my-courses';
  static const String categories = '/categories';

  // Enrollments
  static const String enrollFree = '/enrollments/free';
  static const String myEnrollments = '/enrollments/my-courses';

  // Exams
  static const String exams = '/exams';

  // Certificates
  static const String myCertificates = '/certificates/my-certificates';

  // Payments
  static const String checkout = '/payments/checkout';
  static const String myOrders = '/payments/my-orders';
  static const String myEarnings = '/payments/my-earnings';

  // Progress
  static const String continueWatching = '/progress/continue-watching';

  // Notifications
  static const String notifications = '/notifications';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
