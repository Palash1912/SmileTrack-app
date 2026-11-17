import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/question_card.dart';
import 'ask_question_page.dart';
import 'question_detail_page.dart';

class CommunityPage extends ConsumerWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsStreamProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Q&A'),
        centerTitle: true,
        elevation: 0,
      ),
      body: questionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryMint),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('Error loading questions', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(err.toString(), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(questionsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🤔', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text('No questions yet', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Be the first to ask!', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AskQuestionPage(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ask a Question'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: questions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final question = questions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuestionCard(
                  question: question,
                  onTap: () {
                    // Navigate using Navigator.push instead of GoRouter
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDetailPage(
                          questionId: question.id,
                          question: question,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AskQuestionPage(),
                  ),
                );
              },
              tooltip: 'Ask a Question',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
