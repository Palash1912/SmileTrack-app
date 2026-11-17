import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String displayName;
  final String? avatarUrl;
  final int age;
  final String country;
  final String timezone;
  final DateTime createdAt;
  final int totalPoints;
  final int currentStreak;
  final int maxStreak;
  final List<String> badges;

  const UserModel({
    required this.uid,
    this.email,
    required this.displayName,
    this.avatarUrl,
    required this.age,
    required this.country,
    required this.timezone,
    required this.createdAt,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      displayName: data['display_name'] ?? '',
      avatarUrl: data['avatar_url'],
      age: data['age'] ?? 0,
      country: data['country'] ?? '',
      timezone: data['timezone'] ?? 'UTC',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      totalPoints: data['total_points'] ?? 0,
      currentStreak: data['current_streak'] ?? 0,
      maxStreak: data['max_streak'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedBadges = [];
    if (map['badges'] != null && map['badges'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['badges'].toString());
        if (decoded is List) {
          parsedBadges = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedBadges = map['badges']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String?,
      displayName: map['display_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      age: map['age'] as int? ?? 0,
      country: map['country'] as String? ?? '',
      timezone: map['timezone'] as String? ?? 'UTC',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      totalPoints: map['total_points'] as int? ?? 0,
      currentStreak: map['current_streak'] as int? ?? 0,
      maxStreak: map['max_streak'] as int? ?? 0,
      badges: parsedBadges,
    );
  }

  Map<String, dynamic> toMap({String? password, int isLoggedIn = 0}) => {
        'uid': uid,
        'email': email,
        if (password != null) 'password': password,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'age': age,
        'country': country,
        'timezone': timezone,
        'created_at': createdAt.toIso8601String(),
        'total_points': totalPoints,
        'current_streak': currentStreak,
        'max_streak': maxStreak,
        'badges': jsonEncode(badges),
        'is_logged_in': isLoggedIn,
      };

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'age': age,
        'country': country,
        'timezone': timezone,
        'created_at': Timestamp.fromDate(createdAt),
        'total_points': totalPoints,
        'current_streak': currentStreak,
        'max_streak': maxStreak,
        'badges': badges,
      };

  UserModel copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
    int? age,
    String? country,
    String? timezone,
    int? totalPoints,
    int? currentStreak,
    int? maxStreak,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      badges: badges ?? this.badges,
    );
  }
}