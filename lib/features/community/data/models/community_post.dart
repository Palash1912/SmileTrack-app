import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final String? imageUrl;
  final PostType type;
  final int likesCount;
  final List<String> likedByUserIds;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> tags;
  final bool isAnonymous;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.type,
    required this.isAnonymous,
    this.likesCount = 0,
    this.likedByUserIds = const [],
    this.commentsCount = 0,
    required this.createdAt,
    this.tags = const [],
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      userId: data['user_id'],
      userDisplayName: data['user_display_name'] ?? 'Anonymous',
      userAvatarUrl: data['user_avatar_url'],
      content: data['content'] ?? '',
      imageUrl: data['image_url'],
      type: PostType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => PostType.tip,
      ),
      likesCount: data['likes_count'] ?? 0,
      likedByUserIds: List<String>.from(data['liked_by_user_ids'] ?? []),
      commentsCount: data['comments_count'] ?? 0,
      isAnonymous: false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_id': userId,
        'user_display_name': userDisplayName,
        'user_avatar_url': userAvatarUrl,
        'content': content,
        'image_url': imageUrl,
        'type': type.name,
        'likes_count': likesCount,
        'liked_by_user_ids': likedByUserIds,
        'comments_count': commentsCount,
        'created_at': Timestamp.fromDate(createdAt),
        'tags': tags,
      };
}

enum PostType { tip, achievement, question, motivation }

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory PostComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostComment(
      id: doc.id,
      postId: data['post_id'],
      userId: data['user_id'],
      userDisplayName: data['user_display_name'] ?? 'Anonymous',
      userAvatarUrl: data['user_avatar_url'],
      content: data['content'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
