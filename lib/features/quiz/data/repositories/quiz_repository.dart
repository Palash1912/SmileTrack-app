import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '../models/quiz_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/points_service.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointsService _pointsService = PointsService();

  late final GenerativeModel _gemini = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: AppConstants.geminiApiKey,
  );

  // Fetch daily quiz from Gemini
  Future<QuizQuestion> getDailyQuiz() async {
    try {
      final content = [Content.text(AppConstants.quizPrompt)];
      final response = await _gemini.generateContent(content);
      final text = response.text ?? '';

      // Extract JSON from response
      final jsonStr = _extractJson(text);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return QuizQuestion.fromJson(json);
    } catch (e) {
      // Fallback question
      return const QuizQuestion(
        question: 'How long should you brush your teeth for optimal oral health?',
        options: [
          'A. 30 seconds',
          'B. 1 minute',
          'C. 2 minutes',
          'D. 5 minutes',
        ],
        correctIndex: 2,
        funFact: 'Dentists recommend brushing for at least 2 minutes twice a day to effectively remove plaque and prevent tooth decay.',
      );
    }
  }

  String _extractJson(String text) {
    // Try to extract JSON object from text
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  // Check if user has attempted today's quiz
  Future<QuizAttempt?> getTodayAttempt({required String userId}) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final startOfDay = DateTime.parse('${today}T00:00:00.000Z');
    final endOfDay = DateTime.parse('${today}T23:59:59.999Z');

    final snapshot = await _firestore
        .collection(AppConstants.quizCollection)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return QuizAttempt.fromFirestore(snapshot.docs.first);
  }

  // Save quiz attempt and aggregate points to user total
  Future<QuizAttempt> saveAttempt({
    required String userId,
    required bool isCorrect,
    required int selectedIndex,
  }) async {
    final pointsEarned = isCorrect ? 20 : 5;
    
    final attempt = QuizAttempt(
      id: '',
      userId: userId,
      date: DateTime.now(),
      isCorrect: isCorrect,
      selectedIndex: selectedIndex,
      pointsEarned: pointsEarned,
    );

    final docRef = await _firestore
        .collection(AppConstants.quizCollection)
        .add(attempt.toFirestore());

    // ✅ NEW: Aggregate points to user's total_points
    await _pointsService.addQuizPoints(
      userId: userId,
      pointsEarned: pointsEarned,
    );

    return QuizAttempt(
      id: docRef.id,
      userId: userId,
      date: attempt.date,
      isCorrect: isCorrect,
      selectedIndex: selectedIndex,
      pointsEarned: pointsEarned,
    );
  }

  // Get user's quiz history stats
  Future<Map<String, int>> getQuizStats({required String userId}) async {
    final snapshot = await _firestore
        .collection(AppConstants.quizCollection)
        .where('user_id', isEqualTo: userId)
        .get();

    final total = snapshot.docs.length;
    final correct = snapshot.docs.where((d) => d.data()['is_correct'] == true).length;

    return {'total': total, 'correct': correct};
  }
}
