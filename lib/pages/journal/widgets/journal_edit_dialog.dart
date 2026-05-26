import 'package:flutter/material.dart';

class JournalEditDialog extends StatefulWidget {
  const JournalEditDialog({
    super.key,
    required this.initialContent,
    required this.onSave,
  });

  final String initialContent;
  final Future<void> Function(String updatedContent) onSave;

  @override
  State<JournalEditDialog> createState() => _JournalEditDialogState();
}

class _JournalEditDialogState extends State<JournalEditDialog> {
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑日记'),
      content: TextField(
        controller: _contentController,
        minLines: 6,
        maxLines: 12,
        decoration: const InputDecoration(
          hintText: '修改日记内容',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final updatedContent = _contentController.text.trim();
            if (updatedContent.isEmpty) {
              return;
            }

            await widget.onSave(updatedContent);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
