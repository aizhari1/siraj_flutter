import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/misc_models.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final _service = CertificatesService();
  late Future<List<CertificateModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.myCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شهاداتي'), automaticallyImplyLeading: false),
      body: FutureBuilder<List<CertificateModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: '${snapshot.error}');
          final certs = snapshot.data ?? [];
          if (certs.isEmpty) {
            return const EmptyStateView(
              icon: Icons.workspace_premium_outlined,
              message: 'لسه معندكش شهادات، خلّص كورس عشان تحصل على أول شهادة',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: certs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final cert = certs[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cert.courseTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('رقم الشهادة: ${cert.certificateNo}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (cert.pdfUrl != null)
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                        onPressed: () => launchUrl(Uri.parse(cert.pdfUrl!), mode: LaunchMode.externalApplication),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
