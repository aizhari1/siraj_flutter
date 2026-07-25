import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/misc_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/courses_service.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/course_card.dart';
import 'student_shell.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  final _coursesService = CoursesService();
  final _enrollmentsService = EnrollmentsService();

  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      _enrollmentsService.myCourses(),
      _coursesService.getCourses(),
    ]);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = Future.wait([
        _enrollmentsService.myCourses(),
        _coursesService.getCourses(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سراج'),
        automaticallyImplyLeading: false,
        actions: const [StudentAppBarActions(), SizedBox(width: 8)],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ErrorView(message: '${snapshot.error}', onRetry: _refresh);
            }

            final enrollments = snapshot.data![0] as List<EnrollmentModel>;
            final courses = snapshot.data![1] as List<CourseModel>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أهلاً، ${user?.fullName.split(' ').first ?? ''} 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('كمّل من مكانك وحقق هدفك النهاردة',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(
                  title: 'استكمل التعلّم',
                  actionLabel: enrollments.isNotEmpty ? 'الكل' : null,
                  onAction: () => context.go('/student/courses'),
                ),
                if (enrollments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: EmptyStateView(
                      icon: Icons.school_outlined,
                      message: 'لسه مشتركتش في أي كورس، اكتشف الكورسات المتاحة تحت',
                    ),
                  )
                else
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: enrollments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final e = enrollments[i];
                        return SizedBox(
                          width: 190,
                          child: CourseCard(
                            course: CourseModel(
                              id: e.course.id,
                              title: e.course.title,
                              slug: '',
                              thumbnailUrl: e.course.thumbnailUrl,
                            ),
                            progress: e.progressPercent,
                            onTap: () => context.push('/student/course/${e.course.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                const SectionTitle(title: 'كورسات مقترحة لك'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final c = courses[i];
                    return CourseCard(course: c, onTap: () => context.push('/student/course/${c.id}'));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

