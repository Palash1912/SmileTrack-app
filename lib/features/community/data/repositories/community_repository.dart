import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/answer_model.dart';
import '../../presentation/helpers/file_picker_helper.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Question>> getQuestionsStream() {
    return _firestore
        .collection('questions')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Question.fromFirestore(d)).toList());
  }

  Stream<List<Answer>> getAnswersStream(String questionId) {
    return _firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Answer.fromFirestore(d)).toList());
  }

  Future<Question> postQuestion({
    required String userId,
    required String userDisplayName,
    required String userAvatar,
    required String title,
    required String description,
    List<PickedFile>? images,
    List<PickedFile>? files,
  }) async {
    try {
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadPickedFiles(images, 'questions/images');
      }

      List<String> fileUrls = [];
      if (files != null && files.isNotEmpty) {
        fileUrls = await _uploadPickedFiles(files, 'questions/files');
      }

      final now = DateTime.now();
      final data = {
        'user_id': userId,
        'user_display_name': userDisplayName,
        'user_avatar': userAvatar,
        'title': title,
        'description': description,
        'image_urls': imageUrls,
        'file_urls': fileUrls,
        'created_at': Timestamp.fromDate(now),
        'answer_count': 0,
        'view_count': 0,
      };

      final docRef = await _firestore.collection('questions').add(data);
      print('✅ Question posted: ${docRef.id}');

      return Question(
        id: docRef.id,
        userId: userId,
        userDisplayName: userDisplayName,
        userAvatar: userAvatar,
        title: title,
        description: description,
        imageUrls: imageUrls,
        fileUrls: fileUrls,
        createdAt: now,
      );
    } catch (e) {
      print('❌ Error posting question: $e');
      throw Exception('Failed to post question: $e');
    }
  }

  Future<Answer> postAnswer({
    required String questionId,
    required String userId,
    required String userDisplayName,
    required String userAvatar,
    required String content,
    List<PickedFile>? images,
    List<PickedFile>? files,
  }) async {
    try {
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadPickedFiles(images, 'answers/images');
      }

      List<String> fileUrls = [];
      if (files != null && files.isNotEmpty) {
        fileUrls = await _uploadPickedFiles(files, 'answers/files');
      }

      final now = DateTime.now();
      final data = {
        'question_id': questionId,
        'user_id': userId,
        'user_display_name': userDisplayName,
        'user_avatar': userAvatar,
        'content': content,
        'image_urls': imageUrls,
        'file_urls': fileUrls,
        'created_at': Timestamp.fromDate(now),
        'upvotes': 0,
        'is_accepted': false,
      };

      final docRef = await _firestore
          .collection('questions')
          .doc(questionId)
          .collection('answers')
          .add(data);

      await _firestore.collection('questions').doc(questionId).update({
        'answer_count': FieldValue.increment(1),
      });

      print('✅ Answer posted: ${docRef.id}');

      return Answer(
        id: docRef.id,
        questionId: questionId,
        userId: userId,
        userDisplayName: userDisplayName,
        userAvatar: userAvatar,
        content: content,
        imageUrls: imageUrls,
        fileUrls: fileUrls,
        createdAt: now,
      );
    } catch (e) {
      print('❌ Error posting answer: $e');
      throw Exception('Failed to post answer: $e');
    }
  }

  Future<List<String>> _uploadPickedFiles(
      List<PickedFile> files, String folder) async {
    List<String> urls = [];
    for (final picked in files) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
        final ref = _storage.ref('$folder/$fileName');

        if (kIsWeb && picked.bytes != null) {
          await ref.putData(picked.bytes!);
        } else if (picked.file != null) {
          await ref.putFile(picked.file!);
        } else {
          print('⚠️ Skipping file - no data available: ${picked.name}');
          continue;
        }

        final url = await ref.getDownloadURL();
        urls.add(url);
        print('✅ Uploaded: $fileName');
      } catch (e) {
        print('❌ Upload error: $e');
      }
    }
    return urls;
  }

  Future<void> incrementViewCount(String questionId) async {
    try {
      await _firestore.collection('questions').doc(questionId).update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    await _firestore.collection('questions').doc(questionId).delete();
  }

  Future<void> deleteAnswer(String questionId, String answerId) async {
    await _firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .delete();
    await _firestore.collection('questions').doc(questionId).update({
      'answer_count': FieldValue.increment(-1),
    });
  }

  Future<void> upvoteAnswer(String questionId, String answerId) async {
    await _firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .update({'upvotes': FieldValue.increment(1)});
  }
}
