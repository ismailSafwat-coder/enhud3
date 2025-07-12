import 'question.dart';

class ExamResult {
  final String material;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, String?> userAnswers;
  final List<Question> questions;
  final int timeConsumedInSeconds;
  final DateTime timestamp;

  ExamResult({
    required this.material,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.userAnswers,
    required this.questions,
    required this.timeConsumedInSeconds,
    required this.timestamp,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  int get incorrectAnswers => totalQuestions - correctAnswers;
  int get points => correctAnswers;

  Map<String, dynamic> toJson() {
    return {
      'material': material,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'userAnswers':
          userAnswers.map((key, value) => MapEntry(key.toString(), value)),
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeConsumedInSeconds': timeConsumedInSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final userAnswersMap = Map<String, dynamic>.from(json['userAnswers'] ?? {});
    final questionsList = List<Map<String, dynamic>>.from(
        json['questions']?.map((e) => Map<String, dynamic>.from(e)) ?? []);

    return ExamResult(
      material: json['material'] ?? 'Unknown Material',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      userAnswers: userAnswersMap
          .map((key, value) => MapEntry(int.parse(key), value as String?)),
      questions: questionsList.map((q) => Question.fromJson(q)).toList(),
      timeConsumedInSeconds: json['timeConsumedInSeconds'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
