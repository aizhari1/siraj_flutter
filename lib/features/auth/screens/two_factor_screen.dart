import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/common_widgets.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  final String challengeToken;
  const TwoFactorScreen({super.key, required this.challengeToken});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length < 6) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verify2fa(widget.challengeToken, _codeCtrl.text.trim());
      // الـ router هيوجه المستخدم تلقائيًا بعد التوثيق
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'كود غير صحيح')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق بخطوتين')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.verified_user_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('اكتب كود التحقق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('ابعتنالك كود على تطبيق التوثيق أو البريد المسجل',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(counterText: '', hintText: '------'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'تأكيد', onPressed: _verify, isLoading: _loading),
          ],
        ),
      ),
    );
  }
}
