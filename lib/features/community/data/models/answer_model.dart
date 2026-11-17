import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  final String id;
  final String questionId;
  final String userId;
  final String userDisplayName;
  final String userAvatar;
  final String content;
  final List<String> imageUrls;
  final List<String> fileUrls;
  final DateTime createdAt;
  final int upvotes;
  final bool isAccepted;

  const Answer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatar,
    required this.content,
    this.imageUrls = const [],
    this.fileUrls = const [],
    required this.createdAt,
    this.upvotes = 0,
    this.isAccepted = false,
  });

  factory Answer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Answer(
      id: doc.id,
      questionId: data['question_id'] ?? '',
      userId: data['user_id'] ?? '',
      userDisplayName: data['user_display_name'] ?? '',
      userAvatar: data['user_avatar'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      fileUrls: List<String>.from(data['file_urls'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
      isAccepted: data['is_accepted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'question_id': questionId,
    'user_id': userId,
    'user_display_name': userDisplayName,
    'user_avatar': userAvatar,
    'content': content,
    'image_urls': imageUrls,
    'file_urls': fileUrls,
    'created_at': Timestamp.fromDate(createdAt),
    'upvotes': upvotes,
    'is_accepted': isAccepted,
  };
}
