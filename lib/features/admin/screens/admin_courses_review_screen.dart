import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/courses_service.dart';
import '../../../shared/widgets/common_widgets.dart';

class AdminCoursesReviewScreen extends StatefulWidget {
  const AdminCoursesReviewScreen({super.key});

  @override
  State<AdminCoursesReviewScreen> createState() => _AdminCoursesReviewScreenState();
}

class _AdminCoursesReviewScreenState extends State<AdminCoursesReviewScreen> {
  final _service = CoursesService();
  late Future<List<CourseModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPendingReview();
  }

  void _refresh() => setState(() => _future = _service.getPendingReview());

  Future<void> _approve(CourseModel c) async {
    try {
      await _service.approveCourse(c.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم قبول كورس "${c.title}"')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ')));
    }
  }

  Future<void> _reject(CourseModel c) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض الكورس'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب سبب الرفض للمدرس...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('رفض', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.rejectCourse(c.id, reason: reasonCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفض كورس "${c.title}"')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الكورسات'), automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<CourseModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
            if (snapshot.hasError) return ErrorView(message: '${snapshot.error}', onRetry: _refresh);
            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
              return const EmptyStateView(icon: Icons.task_alt_rounded, message: 'مفيش كورسات في انتظار المراجعة حاليًا');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = courses[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('المدرس: ${c.teacherName ?? "غير معروف"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _reject(c),
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                              label: const Text('رفض', style: TextStyle(color: AppColors.error)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approve(c),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('قبول'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ],
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
