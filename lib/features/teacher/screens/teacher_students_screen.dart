import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/courses_service.dart';
import '../../../shared/widgets/common_widgets.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final _service = CoursesService();
  late Future<List<CourseModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلابي'), automaticallyImplyLeading: false),
      body: FutureBuilder<List<CourseModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const EmptyStateView(message: 'مفيش طلاب لسه، اعمل كورس وانشره الأول');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = courses[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.primarySoft, child: Icon(Icons.groups_rounded, color: AppColors.primary)),
                  title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${c.studentsCount} طالب مشترك في الكورس ده'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () {
                    // اربطها بـ GET /enrollments/course/:courseId/students لعرض قائمة الطلاب بالتفصيل
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
