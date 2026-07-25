import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../models/misc_models.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationsService();
  late Future<List<NotificationModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const EmptyStateView(icon: Icons.notifications_none_rounded, message: 'مفيش إشعارات جديدة دلوقتي');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = items[i];
              return ListTile(
                onTap: () => _service.markRead(n.id),
                leading: CircleAvatar(
                  backgroundColor: n.isRead ? AppColors.surfaceMuted : AppColors.primarySoft,
                  child: Icon(Icons.notifications_rounded, color: n.isRead ? AppColors.textMuted : AppColors.primary, size: 20),
                ),
                title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w800)),
                subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(timeago.format(n.createdAt, locale: 'ar'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              );
            },
          );
        },
      ),
    );
  }
}
