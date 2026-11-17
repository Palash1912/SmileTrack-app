import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/question_model.dart';
import '../../../../core/theme/app_theme.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;

  const QuestionCard({super.key, 
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(question.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: question.userAvatar.isNotEmpty
                      ? NetworkImage(question.userAvatar)
                      : null,
                  child: question.userAvatar.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.userDisplayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              question.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              question.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Images preview
            if (question.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: question.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            question.imageUrls[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Stats footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.comment_outlined,
                        size: 16, color: AppTheme.primaryMint),
                    const SizedBox(width: 6),
                    Text(
                      '${question.answerCount} answers',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined,
                        size: 16, color: AppTheme.primaryMint),
                    const SizedBox(width: 6),
                    Text(
                      '${question.viewCount} views',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (question.fileUrls.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.attach_file,
                          size: 16, color: AppTheme.primaryMint),
                      const SizedBox(width: 6),
                      Text(
                        '${question.fileUrls.length} files',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
