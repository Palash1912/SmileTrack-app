import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String funFact;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.funFact,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'] as int,
      funFact: json['fun_fact'] as String,
    );
  }
}

class QuizAttempt {
  final String id;
  final String userId;
  final DateTime date;
  final bool isCorrect;
  final int selectedIndex;
  final int pointsEarned;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.date,
    required this.isCorrect,
    required this.selectedIndex,
    this.pointsEarned = 0,
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttempt(
      id: doc.id,
      userId: data['user_id'],
      date: (data['date'] as Timestamp).toDate(),
      isCorrect: data['is_correct'] ?? false,
      selectedIndex: data['selected_index'] ?? -1,
      pointsEarned: data['points_earned'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_id': userId,
        'date': Timestamp.fromDate(date),
        'is_correct': isCorrect,
        'selected_index': selectedIndex,
        'points_earned': pointsEarned,
      };
}