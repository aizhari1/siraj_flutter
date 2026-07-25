import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/courses_service.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _usersService = UsersService();
  final _coursesService = CoursesService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      _usersService.getAllUsers(),
      _coursesService.getPendingReview(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم الأدمن'), automaticallyImplyLeading: false),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');

          final users = snapshot.data![0] as List;
          final pending = snapshot.data![1] as List;
          final teachers = users.where((u) => u.role.toString().contains('teacher')).length;
          final students = users.where((u) => u.role.toString().contains('student')).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('نظرة عامة على المنصة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StatCard(label: 'إجمالي المستخدمين', value: '${users.length}', icon: Icons.people_alt_rounded, color: AppColors.adminColor),
                  StatCard(label: 'المدرسين', value: '$teachers', icon: Icons.co_present_rounded, color: AppColors.teacherColor),
                  StatCard(label: 'الطلاب', value: '$students', icon: Icons.school_rounded, color: AppColors.primary),
                  StatCard(label: 'كورسات في الانتظار', value: '${pending.length}', icon: Icons.pending_actions_rounded, color: AppColors.warning),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'كورسات محتاجة مراجعتك'),
              if (pending.isEmpty)
                const EmptyStateView(icon: Icons.check_circle_outline_rounded, message: 'كل الكورسات متراجعة، مفيش حاجة معلقة')
              else
                ...pending.take(5).map((c) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.pending_actions_rounded, color: AppColors.warning)),
                        title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(c.teacherName ?? ''),
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
