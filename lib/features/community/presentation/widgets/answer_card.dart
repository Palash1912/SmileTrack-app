import 'package:flutter/material.dart';
import '../../data/models/answer_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../helpers/file_picker_helper.dart';

class AnswerCard extends StatelessWidget {
  final Answer answer;
  final String questionId;

  const AnswerCard({super.key, 
    required this.answer,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(answer.createdAt);

    return Container(
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
                backgroundImage: answer.userAvatar.isNotEmpty
                    ? NetworkImage(answer.userAvatar)
                    : null,
                child: answer.userAvatar.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.userDisplayName,
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
              if (answer.isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.calGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.calGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.calGreen, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Accepted',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.calGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            answer.content,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Images
          if (answer.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: answer.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          answer.imageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Files
          if (answer.fileUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: answer.fileUrls
                    .asMap()
                    .entries
                    .map((entry) {
                      final url = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppTheme.primaryMint.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file,
                                  color: AppTheme.primaryMint, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  FilePickerHelper.getFileName(url),
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.download,
                                  color: AppTheme.primaryMint, size: 18),
                            ],
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),

          // Stats footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up_outlined,
                      size: 16, color: AppTheme.primaryMint),
                  const SizedBox(width: 6),
                  Text(
                    '${answer.upvotes} upvotes',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.share_outlined,
                      size: 16, color: AppTheme.primaryMint),
                  const SizedBox(width: 6),
                  Text('Share', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ],
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
