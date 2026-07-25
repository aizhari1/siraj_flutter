import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/courses_service.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  final _coursesService = CoursesService();
  final _paymentsService = PaymentsService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      _coursesService.getMyCourses(),
      _paymentsService.myEarnings().catchError((_) => <String, dynamic>{}),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدرس'), automaticallyImplyLeading: false),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');

          final courses = snapshot.data![0] as List;
          final earnings = snapshot.data![1] as Map<String, dynamic>;
          final totalStudents = courses.fold<int>(0, (sum, c) => sum + (c.studentsCount as int));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('أهلاً، ${user?.fullName.split(' ').first ?? ''} 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('نظرة سريعة على أداء كورساتك', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StatCard(label: 'الكورسات', value: '${courses.length}', icon: Icons.video_library_rounded, color: AppColors.primary),
                  StatCard(label: 'الطلاب', value: '$totalStudents', icon: Icons.groups_rounded, color: AppColors.info),
                  StatCard(
                    label: 'الأرباح',
                    value: '${earnings['total'] ?? earnings['totalEarnings'] ?? 0} ج.م',
                    icon: Icons.payments_rounded,
                    color: AppColors.success,
                  ),
                  const StatCard(label: 'التقييم', value: '4.8', icon: Icons.star_rounded, color: AppColors.warning),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'أحدث كورساتك'),
              if (courses.isEmpty)
                const EmptyStateView(icon: Icons.video_library_outlined, message: 'لسه معملتش أي كورس، ابدأ دلوقتي!')
              else
                ...courses.take(5).map((c) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.primarySoft, child: Icon(Icons.play_lesson_rounded, color: AppColors.primary)),
                        title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${c.studentsCount} طالب مشترك'),
                        trailing: const Icon(Icons.chevron_left_rounded),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
