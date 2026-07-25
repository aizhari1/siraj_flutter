import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!_emailCtrl.text.contains('@')) return;
    setState(() => _loading = true);
    try {
      await _authService.forgotPassword(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ، حاول تاني')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? const EmptyStateView(
                icon: Icons.mark_email_read_rounded,
                message: 'لو الإيميل موجود عندنا، هيوصلك رابط استعادة كلمة المرور دلوقتي',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('اكتب بريدك الإلكتروني وهنبعتلك رابط تعمل بيه إعادة تعيين كلمة المرور'),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'البريد الإلكتروني',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: 'إرسال الرابط', onPressed: _submit, isLoading: _loading),
                ],
              ),
      ),
    );
  }
}
