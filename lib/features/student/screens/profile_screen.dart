import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('متأكد إنك عايز تسجل خروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0] : '؟',
                          style: const TextStyle(fontSize: 30, color: AppColors.primary, fontWeight: FontWeight.w800),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Chip(label: Text(_roleLabel(user?.role))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileTile(icon: Icons.person_outline_rounded, label: 'تعديل البيانات الشخصية', onTap: () {}),
          _ProfileTile(icon: Icons.receipt_long_rounded, label: 'طلباتي وفواتيري', onTap: () {}),
          _ProfileTile(icon: Icons.lock_outline_rounded, label: 'تغيير كلمة المرور', onTap: () {}),
          _ProfileTile(icon: Icons.notifications_none_rounded, label: 'إعدادات الإشعارات', onTap: () {}),
          _ProfileTile(icon: Icons.help_outline_rounded, label: 'الدعم والمساعدة', onTap: () {}),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'تسجيل الخروج',
            color: AppColors.error,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.teacher:
        return 'مدرس';
      case UserRole.admin:
        return 'أدمن';
      case UserRole.support:
        return 'دعم فني';
      default:
        return 'طالب';
    }
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: c),
        title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
