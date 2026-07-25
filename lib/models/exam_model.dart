class ExamModel {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final int passingScore;
  final int totalQuestions;
  final int attemptsAllowed;

  ExamModel({
    required this.id,
    required this.title,
    this.description,
    this.durationMinutes = 30,
    this.passingScore = 60,
    this.totalQuestions = 0,
    this.attemptsAllowed = 1,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        durationMinutes: json['durationMinutes'] ?? 30,
        passingScore: json['passingScore'] ?? 60,
        totalQuestions: (json['questions'] as List?)?.length ?? json['totalQuestions'] ?? 0,
        attemptsAllowed: json['attemptsAllowed'] ?? 1,
      );
}

class QuestionModel {
  final String id;
  final String text;
  final List<ChoiceModel> choices;
  final int points;

  QuestionModel({
    required this.id,
    required this.text,
    required this.choices,
    this.points = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id']?.toString() ?? '',
        text: json['text'] ?? json['title'] ?? '',
        points: json['points'] ?? 1,
        choices: ((json['choices'] as List?) ?? [])
            .map((c) => ChoiceModel.fromJson(c))
            .toList(),
      );
}

class ChoiceModel {
  final String id;
  final String text;

  ChoiceModel({required this.id, required this.text});

  factory ChoiceModel.fromJson(Map<String, dynamic> json) => ChoiceModel(
        id: json['id']?.toString() ?? '',
        text: json['text'] ?? '',
      );
}
