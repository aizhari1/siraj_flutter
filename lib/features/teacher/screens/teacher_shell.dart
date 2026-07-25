import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TeacherShell extends StatelessWidget {
  final Widget child;
  const TeacherShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/teacher/courses')) return 1;
    if (location.startsWith('/teacher/students')) return 2;
    if (location.startsWith('/teacher/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      floatingActionButton: currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/teacher/course/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('كورس جديد'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/teacher/home');
              break;
            case 1:
              context.go('/teacher/courses');
              break;
            case 2:
              context.go('/teacher/students');
              break;
            case 3:
              context.go('/teacher/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'لوحة التحكم'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded), label: 'كورساتي'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'الطلاب'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}
