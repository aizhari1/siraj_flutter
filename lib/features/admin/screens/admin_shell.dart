import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/admin/users')) return 1;
    if (location.startsWith('/admin/courses-review')) return 2;
    if (location.startsWith('/admin/profile')) return 3;
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
        selectedItemColor: AppColors.adminColor,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/admin/home');
              break;
            case 1:
              context.go('/admin/users');
              break;
            case 2:
              context.go('/admin/courses-review');
              break;
            case 3:
              context.go('/admin/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_rounded), label: 'المستخدمين'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_rounded), label: 'مراجعة الكورسات'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}
