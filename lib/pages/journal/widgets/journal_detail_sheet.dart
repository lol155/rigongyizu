import 'package:flutter/material.dart';

import '../../../models/journal_entry.dart';
import '../../../utils/app_colors.dart';

class JournalDetailSheet extends StatelessWidget {
  const JournalDetailSheet({
    super.key,
    required this.entry,
    required this.formattedDateTime,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final String formattedDateTime;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.templateName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.text2),
                    onPressed: onCopy,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.text2,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formattedDateTime,
            style: const TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                entry.content,
                style: const TextStyle(fontSize: 15, height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
