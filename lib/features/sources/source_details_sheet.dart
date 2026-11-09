import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:ma3arf/features/feedback/feedback_dialog.dart';

class SourceDetailsSheet extends StatelessWidget {
  final Question question;

  const SourceDetailsSheet({super.key, required this.question});

  static void show(BuildContext context, Question question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SourceDetailsSheet(question: question),
    );
  }

  String _formatSourceTypeName(String type) {
    switch (type) {
      case 'quran':
        return 'القرآن الكريم والتفاسير المعتمدة';
      case 'hadith':
        return 'السنة النبوية والأحاديث الصحيحة';
      case 'sirah':
        return 'السيرة النبوية والمغازي';
      case 'fiqh':
        return 'الفقه الإسلامي وأقوال المذاهب';
      case 'scholarly_consensus':
        return 'إجماع علماء الأمة ومصطلح الأثر';
      default:
        return 'المعارف والآثار الإسلامية المعتمدة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD7B56D).withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7B56D).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      AppIcons.verified,
                      color: Color(0xFFD7B56D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المصدر والتوثيق الشرعي',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'بيان الأدلة والمراجع المعتمدة لهذا السؤال',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: AppIcon(AppIcons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const IslamicDivider(color: Color(0xFFD7B56D), height: 14),
              const SizedBox(height: 12),

              // Question Preview Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF13221C)
                      : const Color(0xFFFBF8F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            question.category,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        if (question.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2E8B68,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon(
                                  AppIcons.checkCircle,
                                  size: 14,
                                  color: Color(0xFF2E8B68),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'موثق ومعتمد',
                                  style: TextStyle(
                                    color: Color(0xFF2E8B68),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Source Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFD7B56D).withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppIcon(
                            AppIcons.learningMode,
                            color: Color(0xFFD7B56D),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'المرجع والمصدر المباشر:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD7B56D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.source.isNotEmpty
                            ? question.source
                            : 'المصادر الإسلامية المعتمدة',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نوع التصنيف: ${_formatSourceTypeName(question.sourceType)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (question.sourceReference.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'رقم الموضع / الآية: ${question.sourceReference}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Educational Explanation Card
              if (question.explanation.isNotEmpty)
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIcon(
                              AppIcons.wisdom,
                              color: Color(0xFF2E8B68),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الشرح والاستدلال:',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E8B68),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.explanation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: AppIcon(AppIcons.copy, size: 18),
                      label: const Text('نسخ المرجع'),
                      onPressed: () {
                        final textToCopy =
                            'السؤال: ${question.question}\nالمصدر: ${question.source}\nالشرح: ${question.explanation}';
                        Clipboard.setData(ClipboardData(text: textToCopy));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ المرجع والتوثيق بنجاح'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton.icon(
                      icon: AppIcon(AppIcons.flag, size: 18),
                      label: const Text('إبلاغ عن ملاحظة'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        FeedbackDialog.show(
                          context,
                          questionId: question.id,
                          questionText: question.question,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
