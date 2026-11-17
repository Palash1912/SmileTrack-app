import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../helpers/file_picker_helper.dart';
import '../providers/community_provider.dart';

class AskQuestionPage extends ConsumerStatefulWidget {
  const AskQuestionPage({super.key});

  @override
  ConsumerState<AskQuestionPage> createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends ConsumerState<AskQuestionPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<PickedFile> selectedImages = [];
  List<PickedFile> selectedFiles = [];
  bool isPosting = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
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

  Future<void> _postQuestion() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isPosting = true);

    try {
      final input = QuestionInput(
        userId: user.uid,
        userDisplayName: user.displayName,
        userAvatar: user.avatarUrl ?? '',
        title: titleController.text,
        description: descriptionController.text,
        images: selectedImages.isNotEmpty ? selectedImages : null,
        files: selectedFiles.isNotEmpty ? selectedFiles : null,
      );

      await ref.read(postQuestionProvider(input).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Question posted successfully!')),
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
        title: const Text('Ask a Question'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question Title', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'What is your question?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            Text('Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Provide more details about your question...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 5,
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
                onPressed: isPosting ? null : _postQuestion,
                child: isPosting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Post Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
