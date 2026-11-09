import 'package:flutter/material.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/features/share/share_service.dart';

class ShareResultDialog extends StatefulWidget {
  final int correctCount;
  final int totalQuestions;
  final int percent;
  final String difficultyName;
  final String category;
  final String quizModeName;
  final List<int>? questionIds;

  const ShareResultDialog({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.percent,
    required this.difficultyName,
    required this.category,
    required this.quizModeName,
    this.questionIds,
  });

  static void show(
    BuildContext context, {
    required int correctCount,
    required int totalQuestions,
    required int percent,
    required String difficultyName,
    required String category,
    required String quizModeName,
    List<int>? questionIds,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ShareResultDialog(
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        percent: percent,
        difficultyName: difficultyName,
        category: category,
        quizModeName: quizModeName,
        questionIds: questionIds,
      ),
    );
  }

  @override
  State<ShareResultDialog> createState() => _ShareResultDialogState();
}

class _ShareResultDialogState extends State<ShareResultDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareText = ShareService.generateShareText(
      score: widget.correctCount,
      totalQuestions: widget.totalQuestions,
      percent: widget.percent,
      difficultyName: widget.difficultyName,
      category: widget.category,
      quizModeName: widget.quizModeName,
      questionIds: widget.questionIds,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shareable Card Widget
            RepaintBoundary(
              key: _cardKey,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B1512),
                      Color(0xFF13221C),
                      Color(0xFF1A3326),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD7B56D),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Stack(
                  children: [
                    // Subtle Islamic Star Watermark
                    const Positioned(
                      top: -20,
                      left: -20,
                      child: IslamicStarPattern(
                        size: 140,
                        color: Color(0xFFD7B56D),
                        opacity: 0.12,
                      ),
                    ),
                    const Positioned(
                      bottom: -20,
                      right: -20,
                      child: IslamicStarPattern(
                        size: 140,
                        color: Color(0xFF2E8B68),
                        opacity: 0.15,
                      ),
                    ),

                    // Card Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIconContainer(
                              icon: AppIcons.mosque,
                              size: 40,
                              iconSize: 22,
                              iconColor: const Color(0xFFD7B56D),
                              backgroundColor: const Color(
                                0xFFD7B56D,
                              ).withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مَعارِف',
                                  style: TextStyle(
                                    color: Color(0xFFF4F1E8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'المنصة التعليمية الإسلامية',
                                  style: TextStyle(
                                    color: Color(0xFFA2B5AB),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const IslamicDivider(
                          color: Color(0xFFD7B56D),
                          height: 16,
                        ),
                        const SizedBox(height: 12),

                        // Badge / Motivational Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              widget.percent >= 80
                                  ? AppIcons.star
                                  : AppIcons.learningMode,
                              color: const Color(0xFFD7B56D),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.percent >= 80
                                  ? 'إنجاز متميز في التحدي'
                                  : 'خطوة في طلب العلم',
                              style: const TextStyle(
                                color: Color(0xFFD7B56D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Score Circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF2E8B68,
                            ).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFF2E8B68),
                              width: 2.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.correctCount} / ${widget.totalQuestions}',
                                style: const TextStyle(
                                  color: Color(0xFFF4F1E8),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.percent}%',
                                style: const TextStyle(
                                  color: Color(0xFFD7B56D),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Details Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildDetailChip(
                              'المستوى: ${widget.difficultyName}',
                            ),
                            _buildDetailChip('التصنيف: ${widget.category}'),
                            _buildDetailChip('النمط: ${widget.quizModeName}'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Invitation Quote
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Text(
                            'تعلّم، راجع، وتحدَّ أصدقاءك في طلب العلم النافع!',
                            style: TextStyle(
                              color: Color(0xFFF4F1E8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Link
                        const Text(
                          'mohamed249k.github.io/Ma3arf',
                          style: TextStyle(
                            color: Color(0xFFD7B56D),
                            fontSize: 11,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons
            Card(
              color: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Share Image Button (Native Image + Text)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7B56D),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : AppIcon(
                                AppIcons.share,
                                size: 20,
                                color: Colors.black,
                              ),
                        label: Text(
                          _isExporting
                              ? 'جارٍ تجهيز البطاقة...'
                              : 'مشاركة بطاقة النتيجة (صورة)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isExporting
                            ? null
                            : () async {
                                setState(() => _isExporting = true);
                                await ShareService.shareImageAndText(
                                  context: context,
                                  cardKey: _cardKey,
                                  text: shareText,
                                );
                                if (mounted) {
                                  setState(() => _isExporting = false);
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // WhatsApp Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: AppIcon(
                          AppIcons.feedback,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'مشاركة عبر واتساب مباشرة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ShareService.shareToWhatsApp(context, shareText);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Copy to Clipboard Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: AppIcon(AppIcons.copy, size: 18),
                        label: const Text('نسخ نص التحدي والرابط'),
                        onPressed: () {
                          ShareService.copyToClipboard(context, shareText);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // General Share Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: AppIcon(AppIcons.share, size: 18),
                        label: const Text('مشاركة عبر التطبيقات الأخرى (نص)'),
                        onPressed: () {
                          ShareService.shareGeneral(context, shareText);
                        },
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Close Button
                    TextButton(
                      child: const Text('إغلاق'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E8B68).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2E8B68).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFF4F1E8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
