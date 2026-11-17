import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/database_helper.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Temporary in-memory OTP stores (for transient OTP verification)
  static final Map<String, String> _emailOtpStore = {};
  static final Map<String, _PendingRegistration> _pendingRegistrations = {};
  static final Map<String, _PendingUpdate> _pendingUpdates = {};
  static final Map<String, _PendingPasswordReset> _pendingPasswordResets = {};

  static UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();
  static const _uuid = Uuid();

  // ─────────────────────────────
  // UTIL
  // ─────────────────────────────
  String generateSixDigitCode() {
    return (100000 + Random.secure().nextInt(900000)).toString();
  }

  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  UserModel? get currentUser => _currentUser;

  // ─────────────────────────────
  // SEND OTP (REGISTER + UPDATE)
  // ─────────────────────────────
  Future<String> sendEmailOtp({
    required BuildContext context,
    required String email,
    required String password,
    required String displayName,
    required int age,
    required String country,
    required String timezone,
    String? newEmail,
    String? newPassword,
  }) async {
    await _fakeDelay();

    final otp = generateSixDigitCode();
    _emailOtpStore[email] = otp;

    // REGISTER
    if (newEmail == null && newPassword == null) {
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('email-already-in-use');
      }

      _pendingRegistrations[email] = _PendingRegistration(
        password: password,
        displayName: displayName,
        age: age,
        country: country,
        timezone: timezone,
      );

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Registration OTP'),
          content: SelectableText(otp),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return otp;
    }

    // UPDATE
    _pendingUpdates[email] = _PendingUpdate(
      newEmail: newEmail,
      newPassword: newPassword,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update OTP'),
        content: SelectableText(otp),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return otp;
  }

  // ─────────────────────────────
  // SEND PASSWORD RESET OTP
  // ─────────────────────────────
  Future<String> sendPasswordResetOtp({
    required BuildContext context,
    required String email,
    required String newPassword,
  }) async {
    await _fakeDelay();

    final user = await _dbHelper.getUserByEmail(email.trim());
    if (user == null) {
      throw Exception('user-not-found');
    }

    final otp = generateSixDigitCode();
    final cleanEmail = email.trim().toLowerCase();
    _emailOtpStore[cleanEmail] = otp;
    _pendingPasswordResets[cleanEmail] = _PendingPasswordReset(
      userId: user.uid,
      newPassword: newPassword,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Password Reset OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Use this 6-digit verification code to complete your password reset:'),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SelectableText(
                  otp,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return otp;
  }

  // ─────────────────────────────
  // VERIFY PASSWORD (FOR SECURITY)
  // ─────────────────────────────
  Future<void> verifyPassword(String? password) async {
    await _fakeDelay();

    if (password == null || password.isEmpty) {
      throw Exception("enter-password");
    }

    final user = _currentUser;
    if (user == null) throw Exception("not-logged-in");

    final savedPassword = await _dbHelper.getPasswordForUser(user.uid);
    if (savedPassword == null) throw Exception("user-not-found");

    if (savedPassword != password) {
      throw Exception("wrong-password");
    }
  }

  // ─────────────────────────────
  // VERIFY OTP (REGISTER + UPDATE)
  // ─────────────────────────────
  Future<UserModel?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    await _fakeDelay();

    final cleanEmail = email.trim().toLowerCase();
    final expectedOtp = _emailOtpStore[cleanEmail] ?? _emailOtpStore[email];
    if (expectedOtp == null) throw Exception('no-otp-sent');
    if (otp != expectedOtp) throw Exception('invalid-otp');

    _emailOtpStore.remove(cleanEmail);
    _emailOtpStore.remove(email);

    // ───────── PASSWORD RESET FLOW ─────────
    final pendingReset =
        _pendingPasswordResets[cleanEmail] ?? _pendingPasswordResets[email];
    if (pendingReset != null) {
      _pendingPasswordResets.remove(cleanEmail);
      _pendingPasswordResets.remove(email);

      await _dbHelper.updatePassword(
        pendingReset.userId,
        pendingReset.newPassword,
      );

      await _dbHelper.setLoggedInUser(pendingReset.userId);
      final activeUser = await _dbHelper.getActiveUser();

      if (activeUser != null) {
        _currentUser = activeUser;
        _authStateController.add(activeUser);
      }
      return activeUser;
    }

    // ───────── UPDATE FLOW ─────────
    final pendingUpdate = _pendingUpdates[email];

    if (pendingUpdate != null) {
      _pendingUpdates.remove(email);

      final current = _currentUser;
      if (current == null) throw Exception('not-authenticated');

      var updatedUser = current;

      // Email update
      if (pendingUpdate.newEmail != null &&
          pendingUpdate.newEmail!.isNotEmpty) {
        final newEmail = pendingUpdate.newEmail!;
        final existing = await _dbHelper.getUserByEmail(newEmail);
        if (existing != null && existing.uid != current.uid) {
          throw Exception('email-already-in-use');
        }
        updatedUser = updatedUser.copyWith(email: newEmail);
      }

      await _dbHelper.updateUser(updatedUser);

      // Password update
      if (pendingUpdate.newPassword != null &&
          pendingUpdate.newPassword!.isNotEmpty) {
        await _dbHelper.updatePassword(
          current.uid,
          pendingUpdate.newPassword!,
        );
      }

      _currentUser = updatedUser;
      _authStateController.add(updatedUser);
      return updatedUser;
    }

    // ───────── REGISTER FLOW ─────────
    final pending = _pendingRegistrations[email];
    if (pending == null) throw Exception('no-pending-registration');

    _pendingRegistrations.remove(email);

    final uid = _uuid.v4();

    final user = UserModel(
      uid: uid,
      email: email,
      displayName: pending.displayName,
      age: pending.age,
      country: pending.country,
      timezone: pending.timezone,
      createdAt: DateTime.now(),
    );

    // Save to local SQLite database with active login state
    await _dbHelper.insertUser(user, pending.password, isLoggedIn: true);

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  // ─────────────────────────────
  // RESEND OTP
  // ─────────────────────────────
  Future<String> resendEmailOtp({
    required BuildContext context,
    required String email,
  }) async {
    await _fakeDelay();

    final cleanEmail = email.trim().toLowerCase();
    if (!_pendingRegistrations.containsKey(email) &&
        !_pendingRegistrations.containsKey(cleanEmail) &&
        !_pendingUpdates.containsKey(email) &&
        !_pendingUpdates.containsKey(cleanEmail) &&
        !_pendingPasswordResets.containsKey(email) &&
        !_pendingPasswordResets.containsKey(cleanEmail)) {
      throw Exception('no-pending-action');
    }

    final otp = generateSixDigitCode();
    _emailOtpStore[email] = otp;
    _emailOtpStore[cleanEmail] = otp;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resent OTP'),
        content: SelectableText(otp),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return otp;
  }

  // ─────────────────────────────
  // LOGIN
  // ─────────────────────────────
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _fakeDelay();

    final user = await _dbHelper.validateCredentials(email, password);
    if (user == null) {
      final exists = await _dbHelper.getUserByEmail(email);
      if (exists == null) {
        throw Exception('user-not-found');
      } else {
        throw Exception('wrong-password');
      }
    }

    // Set as active logged-in user in SQLite
    await _dbHelper.setLoggedInUser(user.uid);

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  // ─────────────────────────────
  // FETCH CURRENT (PERSISTENT CHECK)
  // ─────────────────────────────
  Future<UserModel?> fetchCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final activeUser = await _dbHelper.getActiveUser();
    if (activeUser != null) {
      _currentUser = activeUser;
      _authStateController.add(activeUser);
    }
    return _currentUser;
  }

  // ─────────────────────────────
  // SIGN OUT
  // ─────────────────────────────
  Future<void> signOut() async {
    await _dbHelper.clearActiveUser();
    _currentUser = null;
    _authStateController.add(null);
  }

  // ─────────────────────────────
  // RESET PASSWORD (SIMPLE MOCK)
  // ─────────────────────────────
  Future<void> resetPassword(String email) async {
    await _fakeDelay();

    final user = await _dbHelper.getUserByEmail(email);
    if (user == null) {
      throw Exception('user-not-found');
    }

    print('Password reset requested for $email');
  }

  // ─────────────────────────────
  // UPDATE USER PROFILE
  // ─────────────────────────────
  Future<UserModel?> updateUserProfile(UserModel user) async {
    await _fakeDelay();

    await _dbHelper.updateUser(user);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'country': user.country,
        'timezone': user.timezone,
        'display_name': user.displayName,
        'avatar_url': user.avatarUrl,
        'age': user.age,
      });
    } catch (_) {}

    if (_currentUser?.uid == user.uid) {
      _currentUser = user;
      _authStateController.add(user);
    }

    return user;
  }

  void dispose() => _authStateController.close();

  static Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 300));
}

// ─────────────────────────────
// INTERNAL MODELS
// ─────────────────────────────

class _PendingRegistration {
  final String password;
  final String displayName;
  final int age;
  final String country;
  final String timezone;

  const _PendingRegistration({
    required this.password,
    required this.displayName,
    required this.age,
    required this.country,
    required this.timezone,
  });
}

class _PendingUpdate {
  final String? newEmail;
  final String? newPassword;

  const _PendingUpdate({
    this.newEmail,
    this.newPassword,
  });
}

class _PendingPasswordReset {
  final String userId;
  final String newPassword;

  const _PendingPasswordReset({
    required this.userId,
    required this.newPassword,
  });
}
