import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/storage_service.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDialog extends StatefulWidget {
  final int? relatedQuestionId;
  final String? relatedQuestionText;

  const FeedbackDialog({
    super.key,
    this.relatedQuestionId,
    this.relatedQuestionText,
  });

  static void show(
    BuildContext context, {
    int? questionId,
    String? questionText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FeedbackDialog(
        relatedQuestionId: questionId,
        relatedQuestionText: questionText,
      ),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _selectedTab = 0; // 0 = Suggest Question, 1 = Report Issue

  static const String developerWhatsAppPhone = '201017325592';
  static const String developerWhatsAppDisplay = '01017325592';
  static const String developerName = 'محمد كرم (Mohamed Karam)';

  // Suggest Question Form Controllers
  final _questionCtrl = TextEditingController();
  final _choice0Ctrl = TextEditingController();
  final _choice1Ctrl = TextEditingController();
  final _choice2Ctrl = TextEditingController();
  final _choice3Ctrl = TextEditingController();
  int _correctChoice = 0;
  String _selectedCategory = 'القرآن الكريم';
  String _selectedDifficulty = 'medium';
  final _explanationCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();

  // Report Issue Form Controllers
  String _issueType = 'خطأ في الإجابة';
  final _issueDescCtrl = TextEditingController();
  final _correctionCtrl = TextEditingController();

  final List<String> _issueTypes = [
    'خطأ في الإجابة',
    'خطأ في صياغة السؤال',
    'خطأ لغوي أو إملائي',
    'المصدر غير واضح أو بحاجة لتوثيق',
    'مشكلة تقنية في العرض',
    'اقتراح عام لتطوير المنصة',
  ];

  @override
  void dispose() {
    _questionCtrl.dispose();
    _choice0Ctrl.dispose();
    _choice1Ctrl.dispose();
    _choice2Ctrl.dispose();
    _choice3Ctrl.dispose();
    _explanationCtrl.dispose();
    _sourceCtrl.dispose();
    _issueDescCtrl.dispose();
    _correctionCtrl.dispose();
    super.dispose();
  }

  bool _validateSuggestion() {
    final qText = _questionCtrl.text.trim();
    if (qText.isEmpty) {
      _showError('يرجى كتابة نص السؤال المقترح');
      return false;
    }
    final c0 = _choice0Ctrl.text.trim();
    final c1 = _choice1Ctrl.text.trim();
    final c2 = _choice2Ctrl.text.trim();
    final c3 = _choice3Ctrl.text.trim();
    if (c0.isEmpty || c1.isEmpty || c2.isEmpty || c3.isEmpty) {
      _showError('يرجى إدخال جميع الخيارات الأربعة كاملة');
      return false;
    }
    final choices = [c0, c1, c2, c3];
    if (choices.toSet().length < 4) {
      _showError('يجب أن تكون جميع الخيارات الأربعة مختلفة وغير مكررة');
      return false;
    }
    return true;
  }

  bool _validateReport() {
    if (_issueDescCtrl.text.trim().isEmpty) {
      _showError('يرجى كتابة وصف الملاحظة أو المشكلة بالتفصيل');
      return false;
    }
    return true;
  }

  String _formatSuggestionText() {
    final qText = _questionCtrl.text.trim();
    final c0 = _choice0Ctrl.text.trim();
    final c1 = _choice1Ctrl.text.trim();
    final c2 = _choice2Ctrl.text.trim();
    final c3 = _choice3Ctrl.text.trim();
    final choices = [c0, c1, c2, c3].where((c) => c.isNotEmpty).toList();
    final correctText = [c0, c1, c2, c3][_correctChoice];
    final diffArabic = difficultyNames[_selectedDifficulty] ?? _selectedDifficulty;

    var formatted =
        'السلام عليكم ورحمة الله وبركاته يا أستاذ محمد كرم،\n'
        '🌱 أود اقتراح سؤال جديد موثق لمنصة «مَعارِف»:\n\n'
        '📖 *السؤال:*\n$qText';

    if (choices.isNotEmpty) {
      formatted += '\n\n🔘 *الخيارات المقترحة:*\n';
      for (var i = 0; i < choices.length; i++) {
        formatted += '${i + 1}️⃣ ${choices[i]}\n';
      }
      formatted += '\n✅ *الإجابة الصحيحة:*\n$correctText';
    }

    formatted += '\n\n🏷️ *التصنيف:* $_selectedCategory\n📊 *المستوى المقترح:* $diffArabic';

    final explanation = _explanationCtrl.text.trim();
    if (explanation.isNotEmpty) {
      formatted += '\n\n💡 *الشرح والبيان التوضيحي:*\n$explanation';
    }

    final source = _sourceCtrl.text.trim();
    if (source.isNotEmpty) {
      formatted += '\n\n📚 *المصدر والتوثيق الشرعي:*\n$source';
    }

    formatted += '\n\n— أُرسل عبر منصة مَعارِف للتعليم الإسلامي (صدقة جارية)';
    return formatted;
  }

  String _formatReportText() {
    final target = widget.relatedQuestionText ??
        (widget.relatedQuestionId != null ? 'سؤال رقم ${widget.relatedQuestionId}' : 'سؤال عام في التطبيق');
    final details = _issueDescCtrl.text.trim();
    final correction = _correctionCtrl.text.trim();

    var fullDetails = details;
    if (correction.isNotEmpty) {
      fullDetails += '\n\n💡 التصحيح المقترح:\n$correction';
    }

    return 'السلام عليكم ورحمة الله وبركاته يا أستاذ محمد كرم،\n'
        '⚠️ لدي ملاحظة علمية / بلاغ حول محتوى منصة «مَعارِف»:\n\n'
        '📌 *نوع الملاحظة:* $_issueType\n'
        '🔍 *السؤال المعني / معرّفه:*\n$target\n\n'
        '📝 *تفاصيل الملاحظة ومقترح التصحيح:*\n$fullDetails\n\n'
        '— أُرسل عبر منصة مَعارِف للتعليم الإسلامي (صدقة جارية)';
  }

  Future<void> _saveLocalDraft({bool showNotice = true}) async {
    AudioFeedbackService.instance.playClick();
    if (_selectedTab == 0 && !_validateSuggestion()) return;
    if (_selectedTab == 1 && !_validateReport()) return;

    final drafts = await StorageService.loadFeedbackDrafts();

    if (_selectedTab == 0) {
      final choices = [
        _choice0Ctrl.text.trim(),
        _choice1Ctrl.text.trim(),
        _choice2Ctrl.text.trim(),
        _choice3Ctrl.text.trim(),
      ];
      drafts.add({
        'id': 'draft_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'suggest_question',
        'question': _questionCtrl.text.trim(),
        'choices': choices,
        'correct': _correctChoice,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'explanation': _explanationCtrl.text.trim(),
        'source': _sourceCtrl.text.trim(),
        'date': DateTime.now().toIso8601String(),
      });
    } else {
      drafts.add({
        'id': 'draft_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'report_issue',
        'issueType': _issueType,
        'relatedQuestionId': widget.relatedQuestionId,
        'relatedQuestionText': widget.relatedQuestionText,
        'description': _issueDescCtrl.text.trim(),
        'correction': _correctionCtrl.text.trim(),
        'date': DateTime.now().toIso8601String(),
      });
    }

    await StorageService.saveFeedbackDrafts(drafts);
    if (mounted && showNotice) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ المقترح كمسودة محلية بنجاح على جهازك! جزاك الله خيراً.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendViaWhatsApp() async {
    AudioFeedbackService.instance.playClick();
    if (_selectedTab == 0 && !_validateSuggestion()) return;
    if (_selectedTab == 1 && !_validateReport()) return;

    // Auto save a copy locally
    await _saveLocalDraft(showNotice: false);

    final messageText = _selectedTab == 0 ? _formatSuggestionText() : _formatReportText();
    final encoded = Uri.encodeComponent(messageText);
    final deepLink = Uri.parse('whatsapp://send?phone=$developerWhatsAppPhone&text=$encoded');
    final webLink = Uri.parse('https://api.whatsapp.com/send?phone=$developerWhatsAppPhone&text=$encoded');

    try {
      if (await canLaunchUrl(deepLink)) {
        await launchUrl(deepLink, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop();
      } else if (await canLaunchUrl(webLink)) {
        await launchUrl(webLink, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop();
      } else {
        // Fallback: Copy to clipboard
        await Clipboard.setData(ClipboardData(text: messageText));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح واتساب تلقائياً — تم نسخ نص الرسالة إلى الحافظة بنجاح 📋'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: messageText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ نص الرسالة إلى الحافظة للمشاركة عبر واتساب 📋'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _copyFormattedText() async {
    AudioFeedbackService.instance.playClick();
    if (_selectedTab == 0 && !_validateSuggestion()) return;
    if (_selectedTab == 1 && !_validateReport()) return;

    await _saveLocalDraft(showNotice: false);
    final messageText = _selectedTab == 0 ? _formatSuggestionText() : _formatReportText();

    await Clipboard.setData(ClipboardData(text: messageText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedTab == 0 ? 'تم نسخ نص السؤال المقترح بنجاح 📋' : 'تم نسخ نص الملاحظة بنجاح 📋'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const goldColor = Color(0xFFD7B56D);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: goldColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
                      color: goldColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      AppIcons.edit,
                      color: goldColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ساهم في تطوير مَعارِف',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'اقتراح أسئلة جديدة أو الإبلاغ عن ملاحظات علمية ولغوية',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
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
              const SizedBox(height: 10),

              // Developer direct WhatsApp banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF25D366).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    AppIcon(
                      AppIcons.whatsappFill,
                      size: 20,
                      color: const Color(0xFF25D366),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تواصل مباشر مع المطوّر: $developerName',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'المقترحات والبلاغات تُرسل مباشرة عبر واتساب: $developerWhatsAppDisplay',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const IslamicDivider(height: 14),
              const SizedBox(height: 10),

              // Segmented Tab Selector
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: const Text('اقتراح سؤال'),
                    icon: AppIcon(AppIcons.plus, size: 18),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: const Text('الإبلاغ عن ملاحظة'),
                    icon: AppIcon(AppIcons.flag, size: 18),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (set) => setState(() => _selectedTab = set.first),
              ),
              const SizedBox(height: 14),

              // Disclaimer Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13221C) : const Color(0xFFFBF8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIcon(
                      AppIcons.verified,
                      color: goldColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'أمانة الكلمة: تخضع جميع المقترحات والملاحظات للمراجعة والتدقيق الشرعي واللغوي الدقيق من قبل متخصصين قبل اعتمادها، ولا يتم إدراج أي محتوى في بنك الأسئلة إلا بعد التحقق من صحته.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab 0: Suggest Question Form
              if (_selectedTab == 0) ...[
                TextField(
                  controller: _questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'نص السؤال المقترح *',
                    hintText: 'اكتب صيغة السؤال واضحة ومحددة...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Category & Difficulty Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: categoryIcons.keys.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'المستوى',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: difficultyNames.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDifficulty = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  'خيارات الإجابة (اختر الدائرة بجانب الإجابة الصحيحة):',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildChoiceRow(0, 'أ', _choice0Ctrl),
                const SizedBox(height: 8),
                _buildChoiceRow(1, 'ب', _choice1Ctrl),
                const SizedBox(height: 8),
                _buildChoiceRow(2, 'ج', _choice2Ctrl),
                const SizedBox(height: 8),
                _buildChoiceRow(3, 'د', _choice3Ctrl),
                const SizedBox(height: 12),

                TextField(
                  controller: _explanationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الفائدة والشرح التعليمي',
                    hintText: 'توضيح سبب صحة الإجابة أو الفائدة المستخلصة...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _sourceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'المصدر والمرجع الشرعي',
                    hintText: 'مثال: سورة البقرة: 185 أو صحيح البخاري: 1...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                // Tab 1: Report Issue Form
                DropdownButtonFormField<String>(
                  initialValue: _issueType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الملاحظة',
                    border: OutlineInputBorder(),
                  ),
                  items: _issueTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _issueType = val);
                  },
                ),
                if (widget.relatedQuestionText != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'السؤال المعني: ${widget.relatedQuestionText}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _issueDescCtrl,
                  decoration: const InputDecoration(
                    labelText: 'وصف الملاحظة بالتفصيل *',
                    hintText: 'اشرح ما لاحظته في السؤال أو الإجابة...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _correctionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'التصحيح المقترح (اختياري)',
                    hintText: 'الصواب برأيك أو المرجع الذي يوثق ذلك...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 22),

              // Primary Action: Send via WhatsApp
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _sendViaWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        AppIcons.whatsappFill,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTab == 0
                            ? 'إرسال الاقتراح عبر واتساب'
                            : 'إرسال البلاغ عبر واتساب',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Actions Row: Copy Text & Save Local Draft
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: AppIcon(AppIcons.copy, size: 17),
                        label: Text(
                          _selectedTab == 0 ? 'نسخ الاقتراح' : 'نسخ البلاغ',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _copyFormattedText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: AppIcon(AppIcons.save, size: 17),
                        label: const Text(
                          'حفظ كمسودة',
                          style: TextStyle(fontSize: 12.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _saveLocalDraft(showNotice: true),
                      ),
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

  Widget _buildChoiceRow(int idx, String letter, TextEditingController ctrl) {
    final isCorrect = _correctChoice == idx;
    return Row(
      children: [
        Radio<int>(
          value: idx,
          // ignore: deprecated_member_use
          groupValue: _correctChoice,
          // ignore: deprecated_member_use
          onChanged: (val) {
            if (val != null) setState(() => _correctChoice = val);
          },
        ),
        Text(letter, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: 'الخيار $letter ${isCorrect ? "(الصحيح)" : ""}',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
