import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../services/courses_service.dart';
import '../../../shared/widgets/common_widgets.dart';

class CourseEditorScreen extends StatefulWidget {
  final String? courseId; // null يعني كورس جديد
  const CourseEditorScreen({super.key, this.courseId});

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  final _service = CoursesService();
  bool _saving = false;

  bool get _isEditing => widget.courseId != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = {
        'title': _titleCtrl.text.trim(),
        'shortDescription': _shortDescCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 0,
      };
      if (_isEditing) {
        await _service.updateCourse(widget.courseId!, payload);
      } else {
        await _service.createCourse(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'تم حفظ التعديلات' : 'تم إنشاء الكورس كمسودة')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ، حاول تاني')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitForReview() async {
    if (!_isEditing) return;
    setState(() => _saving = true);
    try {
      await _service.submitForReview(widget.courseId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اتبعت الكورس للمراجعة، هيتراجع من فريق سراج قريبًا')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'حصل خطأ، حاول تاني')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل الكورس' : 'كورس جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'اسم الكورس',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _shortDescCtrl, label: 'وصف مختصر'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'الوصف الكامل'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceCtrl,
                label: 'السعر (اتركه 0 عشان يكون مجاني)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'حفظ', onPressed: _save, isLoading: _saving),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _saving ? null : _submitForReview,
                  child: const Text('إرسال للمراجعة والنشر'),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'ملاحظة: إدارة الدروس، الفيديوهات، والامتحانات التفصيلية تحتاج شاشات منفصلة '
                'يمكن إضافتها لاحقًا وربطها بنفس الـ Endpoints في apps/api/src/modules/course-content و exams.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
