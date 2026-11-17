import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/database_helper.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

// Firebase Auth stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user model provider - StateNotifier for better control
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier() : super(null);

  Future<void> setUser(UserModel? user) async {
    state = user;
  }

  Future<void> refreshFromFirestore(String userId) async {
    try {
      // 1. Refresh from local SQLite database first
      final localUser = await DatabaseHelper().getActiveUser();
      if (localUser != null && localUser.uid == userId) {
        state = localUser;
      }

      // 2. Optional sync from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists) {
          state = UserModel.fromFirestore(doc);
          await DatabaseHelper().updateUser(state!);
        }
      } catch (_) {}
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
}

// Auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
