import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/question_model.dart';
import '../../data/models/answer_model.dart';
import '../../data/repositories/community_repository.dart';
import '../helpers/file_picker_helper.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

final questionsStreamProvider = StreamProvider.autoDispose<List<Question>>((ref) {
  return ref.watch(communityRepositoryProvider).getQuestionsStream();
});

final answersStreamProvider =
    StreamProvider.family.autoDispose<List<Answer>, String>((ref, questionId) {
  return ref.watch(communityRepositoryProvider).getAnswersStream(questionId);
});

final postQuestionProvider =
    FutureProvider.family<Question, QuestionInput>((ref, input) async {
  return ref.read(communityRepositoryProvider).postQuestion(
        userId: input.userId,
        userDisplayName: input.userDisplayName,
        userAvatar: input.userAvatar,
        title: input.title,
        description: input.description,
        images: input.images,
        files: input.files,
      );
});

final postAnswerProvider =
    FutureProvider.family<Answer, AnswerInput>((ref, input) async {
  return ref.read(communityRepositoryProvider).postAnswer(
        questionId: input.questionId,
        userId: input.userId,
        userDisplayName: input.userDisplayName,
        userAvatar: input.userAvatar,
        content: input.content,
        images: input.images,
        files: input.files,
      );
});

class QuestionInput {
  final String userId;
  final String userDisplayName;
  final String userAvatar;
  final String title;
  final String description;
  final List<PickedFile>? images;
  final List<PickedFile>? files;

  QuestionInput({
    required this.userId,
    required this.userDisplayName,
    required this.userAvatar,
    required this.title,
    required this.description,
    this.images,
    this.files,
  });
}

class AnswerInput {
  final String questionId;
  final String userId;
  final String userDisplayName;
  final String userAvatar;
  final String content;
  final List<PickedFile>? images;
  final List<PickedFile>? files;

  AnswerInput({
    required this.questionId,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatar,
    required this.content,
    this.images,
    this.files,
  });
}
