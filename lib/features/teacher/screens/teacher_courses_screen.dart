import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/courses_service.dart';
import '../../../shared/widgets/common_widgets.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final _service = CoursesService();
  late Future<List<CourseModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyCourses();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.getMyCourses());
  }

  Color _statusColor(CourseStatus s) {
    switch (s) {
      case CourseStatus.published:
        return AppColors.success;
      case CourseStatus.pendingReview:
        return AppColors.warning;
      case CourseStatus.rejected:
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(CourseStatus s) {
    switch (s) {
      case CourseStatus.published:
        return 'منشور';
      case CourseStatus.pendingReview:
        return 'قيد المراجعة';
      case CourseStatus.rejected:
        return 'مرفوض';
      case CourseStatus.archived:
        return 'مؤرشف';
      case CourseStatus.draft:
        return 'مسودة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كورساتي'), automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CourseModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
            if (snapshot.hasError) return ErrorView(message: '${snapshot.error}', onRetry: _refresh);
            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
              return const EmptyStateView(icon: Icons.video_library_outlined, message: 'مفيش كورسات لسه، دوس على + لإضافة كورس');
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = courses[i];
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/teacher/course/${c.id}'),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.play_lesson_rounded, color: AppColors.primary),
                    ),
                    title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(c.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_statusLabel(c.status),
                                style: TextStyle(fontSize: 11, color: _statusColor(c.status), fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Text('${c.studentsCount} طالب', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
