import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add points to user's total from quiz attempt
  Future<int> addQuizPoints({
    required String userId,
    required int pointsEarned,
  }) async {
    try {
      // 1. Update points in local SQLite
      final newTotal = await _dbHelper.addPoints(userId, pointsEarned);

      // 2. Optional sync to Firestore
      try {
        final userRef = _firestore.collection('users').doc(userId);
        await userRef.set({'total_points': newTotal}, SetOptions(merge: true));
      } catch (firestoreError) {
        print('Firestore points sync skipped/failed: $firestoreError');
      }

      return newTotal;
    } catch (e) {
      print('Error adding quiz points: $e');
      throw Exception('Failed to add quiz points: $e');
    }
  }

  /// Add points from brushing (morning/evening)
  Future<int> addBrushingPoints({
    required String userId,
    required int pointsEarned,
  }) async {
    try {
      // 1. Update points in local SQLite
      final newTotal = await _dbHelper.addPoints(userId, pointsEarned);

      // 2. Optional sync to Firestore
      try {
        final userRef = _firestore.collection('users').doc(userId);
        await userRef.set({'total_points': newTotal}, SetOptions(merge: true));
      } catch (firestoreError) {
        print('Firestore brushing points sync skipped/failed: $firestoreError');
      }

      return newTotal;
    } catch (e) {
      throw Exception('Failed to add brushing points: $e');
    }
  }

  /// Get aggregated points from all sources for a user
  Future<int> getTotalPoints({required String userId}) async {
    try {
      final user = await _dbHelper.getActiveUser();
      if (user != null && user.uid == userId) {
        return user.totalPoints;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      return (userDoc.data()?['total_points'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate total points from scratch (quiz + brushing)
  Future<int> recalculateTotalPoints({required String userId}) async {
    try {
      int brushingPoints = 0;
      final logs = await _dbHelper.getAllLogsForUser(userId);
      for (var log in logs) {
        brushingPoints += log.pointsEarned;
      }

      int quizPoints = 0;
      try {
        final quizSnapshot = await _firestore
            .collection('quiz_attempts')
            .where('user_id', isEqualTo: userId)
            .get();

        for (var doc in quizSnapshot.docs) {
          quizPoints += (doc.data()['points_earned'] as int?) ?? 0;
        }
      } catch (_) {}

      final totalPoints = quizPoints + brushingPoints;

      await _dbHelper.addPoints(userId, totalPoints);

      try {
        await _firestore.collection('users').doc(userId).set({
          'total_points': totalPoints,
        }, SetOptions(merge: true));
      } catch (_) {}

      return totalPoints;
    } catch (e) {
      return 0;
    }
  }
}
