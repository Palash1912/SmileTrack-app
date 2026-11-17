import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userAvatar;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> fileUrls;
  final DateTime createdAt;
  final int answerCount;
  final int viewCount;

  const Question({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatar,
    required this.title,
    required this.description,
    this.imageUrls = const [],
    this.fileUrls = const [],
    required this.createdAt,
    this.answerCount = 0,
    this.viewCount = 0,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      userId: data['user_id'] ?? '',
      userDisplayName: data['user_display_name'] ?? '',
      userAvatar: data['user_avatar'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      fileUrls: List<String>.from(data['file_urls'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      answerCount: data['answer_count'] ?? 0,
      viewCount: data['view_count'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'user_id': userId,
    'user_display_name': userDisplayName,
    'user_avatar': userAvatar,
    'title': title,
    'description': description,
    'image_urls': imageUrls,
    'file_urls': fileUrls,
    'created_at': Timestamp.fromDate(createdAt),
    'answer_count': answerCount,
    'view_count': viewCount,
  };
}
