import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../services/lms_services.dart';
import '../../../shared/widgets/common_widgets.dart';

class ExamScreen extends StatefulWidget {
  final String examId;
  const ExamScreen({super.key, required this.examId});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _service = ExamsService();
  ExamModel? _exam;
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;
  final Map<String, String> _answers = {}; // questionId -> choiceId
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final exam = await _service.getExam(widget.examId);
      setState(() {
        _exam = exam;
        _remainingSeconds = exam.durationMinutes * 60;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitExam();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _submitExam() async {
    _timer?.cancel();
    // ملاحظة: اربط هنا endpoint تسليم الامتحان الفعلي من الباك ايند
    // (مثال: POST /exams/:id/attempts/:attemptId/submit) حسب الـ DTO بتاعك
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('تم تسليم الامتحان'),
        content: Text('جاوبت على ${_answers.length} من ${_exam?.totalQuestions ?? 0} سؤال'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingView());
    if (_error != null) return Scaffold(body: ErrorView(message: _error!, onRetry: _load));

    final exam = _exam!;

    return Scaffold(
      appBar: AppBar(
        title: Text(exam.title),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60 ? AppColors.error.withValues(alpha: 0.1) : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: _remainingSeconds < 60 ? AppColors.error : AppColors.primary),
                const SizedBox(width: 4),
                Text(_formattedTime,
                    style: TextStyle(
                        color: _remainingSeconds < 60 ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
      body: exam.totalQuestions == 0
          ? const EmptyStateView(message: 'لا يوجد أسئلة في هذا الامتحان')
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / exam.totalQuestions,
                  backgroundColor: AppColors.surfaceMuted,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'السؤال ${_currentIndex + 1} من ${exam.totalQuestions}\n\n'
                      'ملاحظة: اربط هنا الأسئلة الفعلية القادمة من الـ API '
                      '(GET /exams/:id بيرجع الأسئلة والاختيارات)',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentIndex--),
                            child: const Text('السابق'),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: _currentIndex == exam.totalQuestions - 1 ? 'تسليم الامتحان' : 'التالي',
                          onPressed: () {
                            if (_currentIndex == exam.totalQuestions - 1) {
                              _submitExam();
                            } else {
                              setState(() => _currentIndex++);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
