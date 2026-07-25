import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/student/courses')) return 1;
    if (location.startsWith('/student/certificates')) return 2;
    if (location.startsWith('/student/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/student/home');
              break;
            case 1:
              context.go('/student/courses');
              break;
            case 2:
              context.go('/student/certificates');
              break;
            case 3:
              context.go('/student/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'كورساتي'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_rounded), label: 'الشهادات'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}

/// أيقونة موحدة تُستخدم في الـ AppBar لباقي شاشات الطالب
class StudentAppBarActions extends StatelessWidget {
  const StudentAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
      onPressed: () => context.push('/student/notifications'),
    );
  }
}
