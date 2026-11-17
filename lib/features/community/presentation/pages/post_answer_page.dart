import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../helpers/file_picker_helper.dart';
import '../providers/community_provider.dart';

class PostAnswerPage extends ConsumerStatefulWidget {
  final String questionId;
  const PostAnswerPage({super.key, required this.questionId});

  @override
  ConsumerState<PostAnswerPage> createState() => _PostAnswerPageState();
}

class _PostAnswerPageState extends ConsumerState<PostAnswerPage> {
  final contentController = TextEditingController();
  List<PickedFile> selectedImages = [];
  List<PickedFile> selectedFiles = [];
  bool isPosting = false;

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await FilePickerHelper.pickImages();
    setState(() => selectedImages.addAll(images));
  }

  Future<void> _pickFiles() async {
    final files = await FilePickerHelper.pickFiles();
    setState(() => selectedFiles.addAll(files));
  }

  Future<void> _postAnswer() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write an answer')),
      );
      return;
    }

    setState(() => isPosting = true);

    try {
      final input = AnswerInput(
        questionId: widget.questionId,
        userId: user.uid,
        userDisplayName: user.displayName,
        userAvatar: user.avatarUrl ?? '',
        content: contentController.text,
        images: selectedImages.isNotEmpty ? selectedImages : null,
        files: selectedFiles.isNotEmpty ? selectedFiles : null,
      );

      await ref.read(postAnswerProvider(input).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Answer posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post an Answer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Answer', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: 'Write your answer here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 24),

            Text('Add Images', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final picked = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.image, color: AppTheme.primaryMint),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              picked.name,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => selectedImages.removeAt(index)),
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Pick Images'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMint),
            ),
            const SizedBox(height: 24),

            Text('Add Files', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (selectedFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final picked = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: AppTheme.primaryMint),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              picked.name,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => selectedFiles.removeAt(index)),
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Pick Files'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMint),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPosting ? null : _postAnswer,
                child: isPosting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Post Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
