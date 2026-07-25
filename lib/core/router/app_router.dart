import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/two_factor_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

import '../../features/student/screens/student_shell.dart';
import '../../features/student/screens/home_screen.dart';
import '../../features/student/screens/courses_list_screen.dart';
import '../../features/student/screens/course_detail_screen.dart';
import '../../features/student/screens/certificates_screen.dart';
import '../../features/student/screens/profile_screen.dart';
import '../../features/student/screens/notifications_screen.dart';
import '../../features/student/screens/checkout_webview_screen.dart';
import '../../features/student/screens/exam_screen.dart';

import '../../features/teacher/screens/teacher_shell.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_courses_screen.dart';
import '../../features/teacher/screens/course_editor_screen.dart';
import '../../features/teacher/screens/teacher_students_screen.dart';

import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_courses_review_screen.dart';

/// يحدد الصفحة الرئيسية حسب دور المستخدم بعد تسجيل الدخول
String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.teacher:
      return '/teacher/home';
    case UserRole.admin:
    case UserRole.support:
      return '/admin/home';
    case UserRole.student:
      return '/student/home';
  }
}

class AppRouter {
  static GoRouter build(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthListenable(ref),
      redirect: (context, state) {
        final auth = ref.read(authProvider);
        final loc = state.matchedLocation;
        final isAuthRoute = loc.startsWith('/login') ||
            loc.startsWith('/register') ||
            loc.startsWith('/two-factor') ||
            loc.startsWith('/forgot-password');

        if (auth.status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        if (auth.status == AuthStatus.unauthenticated) {
          return isAuthRoute ? null : '/login';
        }

        // authenticated
        if (loc == '/splash' || isAuthRoute) {
          return _homeForRole(auth.user?.role ?? UserRole.student);
        }

        // امنع دخول دور لمنطقة دور تاني (مثال: طالب يحاول يدخل /admin)
        final role = auth.user?.role ?? UserRole.student;
        if (loc.startsWith('/teacher') && role != UserRole.teacher) {
          return _homeForRole(role);
        }
        if (loc.startsWith('/admin') && role != UserRole.admin && role != UserRole.support) {
          return _homeForRole(role);
        }
        if (loc.startsWith('/student') && role != UserRole.student) {
          return _homeForRole(role);
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(
          path: '/two-factor',
          builder: (context, state) => TwoFactorScreen(challengeToken: state.extra as String? ?? ''),
        ),

        // ---------------- الطالب ----------------
        ShellRoute(
          builder: (context, state, child) => StudentShell(child: child),
          routes: [
            GoRoute(path: '/student/home', builder: (context, state) => const StudentHomeScreen()),
            GoRoute(path: '/student/courses', builder: (context, state) => const CoursesListScreen()),
            GoRoute(path: '/student/certificates', builder: (context, state) => const CertificatesScreen()),
            GoRoute(path: '/student/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
        GoRoute(
          path: '/student/course/:id',
          builder: (context, state) => CourseDetailScreen(courseId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/student/exam/:id',
          builder: (context, state) => ExamScreen(examId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/student/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/student/checkout',
          builder: (context, state) => CheckoutWebViewScreen(checkoutUrl: state.extra as String? ?? ''),
        ),

        // ---------------- المدرس ----------------
        ShellRoute(
          builder: (context, state, child) => TeacherShell(child: child),
          routes: [
            GoRoute(path: '/teacher/home', builder: (context, state) => const TeacherDashboardScreen()),
            GoRoute(path: '/teacher/courses', builder: (context, state) => const TeacherCoursesScreen()),
            GoRoute(path: '/teacher/students', builder: (context, state) => const TeacherStudentsScreen()),
            GoRoute(path: '/teacher/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
        GoRoute(
          path: '/teacher/course/new',
          builder: (context, state) => const CourseEditorScreen(),
        ),
        GoRoute(
          path: '/teacher/course/:id',
          builder: (context, state) => CourseEditorScreen(courseId: state.pathParameters['id']),
        ),

        // ---------------- الأدمن ----------------
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin/home', builder: (context, state) => const AdminDashboardScreen()),
            GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
            GoRoute(path: '/admin/courses-review', builder: (context, state) => const AdminCoursesReviewScreen()),
            GoRoute(path: '/admin/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
      ],
    );
  }
}

/// يوصل تغييرات حالة الـ Auth بالـ GoRouter عشان يعيد التوجيه أوتوماتيكيًا
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this.ref) {
    _subscription = ref.listenManual(authProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
  final WidgetRef ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
