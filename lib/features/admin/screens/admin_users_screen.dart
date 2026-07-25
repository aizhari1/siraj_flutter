import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = UsersService();
  late Future<List<UserModel>> _future;
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllUsers();
  }

  void _refresh() {
    setState(() => _future = _service.getAllUsers(role: _roleFilter));
  }

  Future<void> _toggleStatus(UserModel u) async {
    try {
      await _service.updateUserStatus(u.id, !u.isActive);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ، حاول تاني')),
      );
    }
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.teacher:
        return 'مدرس';
      case UserRole.admin:
        return 'أدمن';
      case UserRole.support:
        return 'دعم';
      default:
        return 'طالب';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _FilterChip(label: 'الكل', selected: _roleFilter == null, onTap: () {
                  setState(() => _roleFilter = null);
                  _refresh();
                }),
                const SizedBox(width: 8),
                _FilterChip(label: 'طلاب', selected: _roleFilter == 'STUDENT', onTap: () {
                  setState(() => _roleFilter = 'STUDENT');
                  _refresh();
                }),
                const SizedBox(width: 8),
                _FilterChip(label: 'مدرسين', selected: _roleFilter == 'TEACHER', onTap: () {
                  setState(() => _roleFilter = 'TEACHER');
                  _refresh();
                }),
                const SizedBox(width: 8),
                _FilterChip(label: 'أدمن', selected: _roleFilter == 'ADMIN', onTap: () {
                  setState(() => _roleFilter = 'ADMIN');
                  _refresh();
                }),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
                if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');
                final users = snapshot.data ?? [];
                if (users.isEmpty) return const EmptyStateView(message: 'مفيش مستخدمين مطابقين');
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Text(u.fullName.isNotEmpty ? u.fullName[0] : '؟',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ),
                        title: Text(u.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${u.email} • ${_roleLabel(u.role)}'),
                        trailing: Switch(
                          value: u.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (_) => _toggleStatus(u),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.adminColor : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
