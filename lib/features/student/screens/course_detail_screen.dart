import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../services/courses_service.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _coursesService = CoursesService();
  final _enrollmentsService = EnrollmentsService();
  final _paymentsService = PaymentsService();

  CourseModel? _course;
  bool _loading = true;
  bool _enrolling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // ملاحظة: الـ API الحالي بيرجع بالـ slug، فهنا بنفترض إن الـ id بيشتغل كمعرف بديل.
      // لو محتاج تجيب بالـ id مباشرة أضف endpoint GET /courses/:id في الباك ايند.
      final c = await _coursesService.getCourseBySlug(widget.courseId);
      setState(() => _course = c);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleEnroll() async {
    if (_course == null) return;
    setState(() => _enrolling = true);
    try {
      if (_course!.isFree) {
        await _enrollmentsService.enrollFree(_course!.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الاشتراك بنجاح! ابدأ التعلم دلوقتي')),
        );
        context.pop();
      } else {
        final url = await _paymentsService.createCheckoutUrl(_course!.id);
        if (!mounted) return;
        context.push('/student/checkout', extra: url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ، حاول تاني')),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingView());
    if (_error != null) return Scaffold(body: ErrorView(message: _error!, onRetry: _load));
    final course = _course!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: course.thumbnailUrl != null
                  ? CachedNetworkImage(imageUrl: course.thumbnailUrl!, fit: BoxFit.cover)
                  : Container(color: AppColors.primarySoft),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.categoryName != null)
                    Chip(label: Text(course.categoryName!)),
                  const SizedBox(height: 10),
                  Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(course.teacherName ?? 'مدرس سراج', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(course.rating.toStringAsFixed(1)),
                      const SizedBox(width: 16),
                      const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${course.studentsCount} طالب'),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('عن الكورس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? course.shortDescription ?? 'لا يوجد وصف متاح لهذا الكورس حاليًا',
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!course.isFree)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '${course.price.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              Expanded(
                child: PrimaryButton(
                  label: course.isFree ? 'اشترك مجانًا' : 'اشترك الآن',
                  onPressed: _handleEnroll,
                  isLoading: _enrolling,
                  icon: Icons.play_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
