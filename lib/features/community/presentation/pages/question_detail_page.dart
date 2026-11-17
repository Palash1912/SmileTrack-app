import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/models/question_model.dart';
import '../helpers/file_picker_helper.dart';
import '../providers/community_provider.dart';
import '../widgets/answer_card.dart';
import 'post_answer_page.dart';

class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionId;
  final Question question;

  const QuestionDetailPage({super.key, 
    required this.questionId,
    required this.question,
  });

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Increment view count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityRepositoryProvider).incrementViewCount(widget.questionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final answersAsync = ref.watch(answersStreamProvider(widget.questionId));
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.question.userAvatar.isNotEmpty
                            ? NetworkImage(widget.question.userAvatar)
                            : null,
                        child: widget.question.userAvatar.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.question.userDisplayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getTimeAgo(widget.question.createdAt),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.question.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    widget.question.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Images
                  if (widget.question.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.question.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.question.imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Files
                  if (widget.question.fileUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Attached Files:', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Column(
                      children: widget.question.fileUrls
                          .asMap()
                          .entries
                          .map((entry) {
                            final url = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: theme.colorScheme.outline),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file,
                                        color: AppTheme.primaryMint),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        FilePickerHelper.getFileName(url),
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.download,
                                        color: AppTheme.primaryMint, size: 20),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(),

            // Answers section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Answers (${widget.question.answerCount})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            answersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryMint),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (answers) {
                if (answers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No answers yet. Be the first to answer!',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: AnswerCard(
                        answer: answers[index],
                        questionId: widget.questionId,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostAnswerPage(
                      questionId: widget.questionId,
                    ),
                  ),
                );
              },
              tooltip: 'Post Answer',
              child: const Icon(Icons.reply),
            )
          : null,
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
