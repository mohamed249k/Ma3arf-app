import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_footer.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

/// Privacy Policy Screen for Ma3arf
/// Matches the official reference web page:
/// https://mohamed249k.github.io/Ma3arf/privacy.html
///
/// Features:
/// 1. Exact 10 sections from the website with full legal and Islamic disclosures.
/// 2. Google Play Console compliance (Zero tracking, COPPA, offline local storage).
/// 3. Toggle between Full Arabic text and Full English text.
/// 4. Direct action to copy the permanent Google Play Policy URL.
/// 5. Direct WhatsApp developer contact for privacy and question suggestions.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  static const String policyUrl = 'https://mohamed249k.github.io/Ma3arf/privacy.html';
  static const String developerWhatsAppPhone = '201017325592';
  static const String developerWhatsAppDisplay = '01017325592';
  static const String developerName = 'محمد كرم (Mohamed Karam)';

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isEnglish = false;

  Future<void> _copyPolicyUrl(BuildContext context) async {
    AudioFeedbackService.instance.playClick();
    await Clipboard.setData(const ClipboardData(text: PrivacyPolicyScreen.policyUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم نسخ رابط سياسة الخصوصية لمتجر Google Play بنجاح 📋',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Color(0xFF1E5D44),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _contactWhatsApp(BuildContext context) async {
    AudioFeedbackService.instance.playClick();
    const greeting =
        'السلام عليكم ورحمة الله وبركاته يا أستاذ محمد كرم،\n'
        'أتواصل معك بخصوص سياسة الخصوصية لمنصة «مَعارِف»:';
    final deepLink = Uri.parse(
      'whatsapp://send?phone=${PrivacyPolicyScreen.developerWhatsAppPhone}&text=${Uri.encodeComponent(greeting)}',
    );
    final webLink = Uri.parse(
      'https://api.whatsapp.com/send?phone=${PrivacyPolicyScreen.developerWhatsAppPhone}&text=${Uri.encodeComponent(greeting)}',
    );

    try {
      if (await canLaunchUrl(deepLink)) {
        await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webLink)) {
        await launchUrl(webLink, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(
          const ClipboardData(text: PrivacyPolicyScreen.developerWhatsAppDisplay),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نسخ رقم واتساب المطوّر (01017325592) بنجاح 📋'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: PrivacyPolicyScreen.developerWhatsAppDisplay),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ رقم واتساب المطوّر (01017325592) بنجاح 📋'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>();
    final primaryGold = appColors?.gold ?? AppGold.primary;
    final cardBg = isDark ? const Color(0xFF13241C) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF263D31)
        : (appColors?.border ?? const Color(0xFFE2D6C3));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEnglish ? 'Privacy Policy' : 'سياسة الخصوصية',
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'نسخ رابط السياسة',
            icon: AppIcon(AppIcons.copy, color: primaryGold, size: 20),
            onPressed: () => _copyPolicyUrl(context),
          ),
          IconButton(
            tooltip: 'مراسلة المطور عبر واتساب',
            icon: AppIcon(AppIcons.whatsappFill, color: const Color(0xFF25D366), size: 20),
            onPressed: () => _contactWhatsApp(context),
          ),
        ],
      ),
      body: IslamicGeometricBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 1. HERO HEADER CARD (Matching Web)
              // ==========================================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: borderColor),
                ),
                color: cardBg,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              AppIcons.shieldCheck,
                              size: 16,
                              color: primaryGold,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isEnglish
                                    ? 'Official Verified Google Play Policy Document'
                                    : 'وثيقة معتمدة لمتجر Google Play والتطبيق الرسمي',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFC7E2D5) : const Color(0xFF1B533E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        _isEnglish
                            ? 'Privacy Policy & User Data Protection'
                            : 'سياسة الخصوصية وحماية بيانات المستخدم',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: primaryGold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        _isEnglish
                            ? 'Ma3arf (معارف) Islamic Knowledge & Quiz Platform — An educational endowment (Sadaqah Jariyah) dedicated purely for Allah. We uphold the highest privacy, transparency, and family safety standards.'
                            : 'تطبيق ومنصة «مَعارِف | Ma3arf» للعلوم والمسابقات الإسلامية — وقفٌ تعليمي خالص لوجه الله تبارك وتعالى وصدقة جارية. نلتزم بأعلى معايير الأمان والشفافية لحماية خصوصية المستخدمين والأسر والأطفال.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          height: 1.55,
                          color: isDark ? const Color(0xFFA5B8AD) : const Color(0xFF4A6155),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Meta badges wrap
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildMetaChip(
                            icon: AppIcons.badge,
                            label: _isEnglish ? 'v3.0 Ultra Pro' : 'الإصدار: 3.0',
                            isDark: isDark,
                            primaryGold: primaryGold,
                          ),
                          _buildMetaChip(
                            icon: AppIcons.calendar,
                            label: _isEnglish ? 'Nov 2026' : 'نوفمبر 2026',
                            isDark: isDark,
                            primaryGold: primaryGold,
                          ),
                          _buildMetaChip(
                            icon: AppIcons.profile,
                            label: _isEnglish ? 'Mohamed Karam' : 'محمد كرم',
                            isDark: isDark,
                            primaryGold: primaryGold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Language Toggle Buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('العربية (Arabic)'),
                            selected: !_isEnglish,
                            onSelected: (val) {
                              if (val) setState(() => _isEnglish = false);
                            },
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: !_isEnglish ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('English (الإنجليزية)'),
                            selected: _isEnglish,
                            onSelected: (val) {
                              if (val) setState(() => _isEnglish = true);
                            },
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: _isEnglish ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 2. QUICK ACTIONS BAR
              // ==========================================
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor.withValues(alpha: 0.7)),
                ),
                color: isDark ? const Color(0xFF0F1E17) : const Color(0xFFF9F7F2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          AppIcon(AppIcons.copy, size: 16, color: primaryGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEnglish
                                  ? 'Permanent Google Play Console URL:'
                                  : 'رابط السياسة الدائم لمتجر Google Play:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        PrivacyPolicyScreen.policyUrl,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isDark ? const Color(0xFF90A79A) : const Color(0xFF5A7264),
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              side: BorderSide(color: primaryGold.withValues(alpha: 0.6)),
                            ),
                            icon: AppIcon(AppIcons.copy, size: 15, color: primaryGold),
                            label: Text(
                              _isEnglish ? 'Copy URL' : 'نسخ الرابط',
                              style: TextStyle(color: primaryGold, fontSize: 11.5),
                            ),
                            onPressed: () => _copyPolicyUrl(context),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            ),
                            icon: AppIcon(AppIcons.whatsappFill, size: 15, color: Colors.white),
                            label: Text(
                              _isEnglish ? 'WhatsApp' : 'واتساب المطوّر',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _contactWhatsApp(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 3. MAIN POLICY CONTENT SECTIONS
              // ==========================================
              if (!_isEnglish) ..._buildArabicSections(cardBg, borderColor, primaryGold, isDark)
              else ..._buildEnglishSections(cardBg, borderColor, primaryGold, isDark),

              const SizedBox(height: 20),

              // ==========================================
              // 4. OFFICIAL APP FOOTER
              // ==========================================
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color primaryGold,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E17) : const Color(0xFFF4EFE6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 12, color: primaryGold),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? const Color(0xFFB5C9BD) : const Color(0xFF3C5346),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String number,
    required String title,
    required List<Widget> children,
    required Color cardBg,
    required Color borderColor,
    required Color primaryGold,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          height: 1.6,
          color: isDark ? const Color(0xFFD3E0D8) : const Color(0xFF283A31),
        ),
      ),
    );
  }

  Widget _buildBulletItem(String title, String body, bool isDark, Color primaryGold) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: primaryGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  height: 1.55,
                  color: isDark ? const Color(0xFFC7D6CC) : const Color(0xFF283A31),
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF14291E),
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildArabicSections(
    Color cardBg,
    Color borderColor,
    Color primaryGold,
    bool isDark,
  ) {
    return [
      _buildSectionCard(
        number: '١',
        title: 'مقدمة وهوية التطبيق والهدف الوقفـي',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'مرحباً بكم في «مَعارِف | Ma3arf»، المنصة والتطبيق التعليمي التفاعلي المخصص لنشر العلوم الإسلامية الموثقة، وتثبيت معارف القرآن الكريم وصحيح السنة النبوية المطهرة وسيرة المصطفى ﷺ وتاريخ الصحابة الكرام وفق مصادر أهل السنة والجماعة المعتمدة.',
            isDark,
          ),
          _buildParagraph(
            'هذا التطبيق هو وقفٌ تعليمي لوجه الله تبارك وتعالى وصدقة جارية، أُعِدَّ ونُفِّذ بجهود ذاتية تطوعية من المطور محمد كرم (Mohamed Karam)، دون أي أهداف تجارية أو ربحية.',
            isDark,
          ),
          _buildParagraph(
            'الهدف الأسمى لتطبيق «مَعارِف» هو تقديم علم نافع متاح بالمجان لكل مسلم ومسلمة في شتى بقاع الأرض، مع صيانة خصوصية كل مستخدم والحرص التام على أمان بياناته.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '٢',
        title: 'عدم جمع أي بيانات شخصية (Zero Personal Data)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'وفقاً للمبادئ الشرعية الإسلامية وسياسات مطوري Google Play العالمية، نؤكد بصريح العبارة: إن تطبيق «مَعارِف» لا يطلب، ولا يجمع، ولا يسجل، ولا يخزن على أي خوادم خارجية، ولا يبيع، ولا يشارك أي معلومات شخصية تعريفية (Personally Identifiable Information - PII) تخص المستخدم إطلاقاً.',
            isDark,
          ),
          _buildBulletItem('الاسم الحقيقي أو الهوية', 'لا يتطلب التطبيق تسجيل حساب رسمي أو إدخال رقم هوية أو بريد.', isDark, primaryGold),
          _buildBulletItem('البريد الإلكتروني أو كلمات المرور', 'لا يوجد نظام تسجيل دخول بالبريد أو المصادقة السحابية.', isDark, primaryGold),
          _buildBulletItem('أرقام الهواتف أو جهات الاتصال', 'لا يصل التطبيق إلى دليل هواتف المستخدم إطلاقاً.', isDark, primaryGold),
          _buildBulletItem('الموقع الجغرافي (GPS أو Network)', 'لا يطلب التطبيق ولا يتعقب موقع المستخدم نهائياً.', isDark, primaryGold),
          _buildBulletItem('الصور والملفات والكاميرا', 'لا يطلب التطبيق أي وصول لوسائط الهاتف أو الكاميرا.', isDark, primaryGold),
          _buildBulletItem('المعرفات الإعلانية (GAID)', 'التطبيق خالٍ تماماً من أكواد التتبع الإعلاني.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '٣',
        title: 'التخزين المحلي والتشغيل دون اتصال (Offline-First)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'يعتمد تطبيق «مَعارِف» على معمارية التخزين المحلي التام (SharedPreferences) داخل مساحة الذاكرة المخصصة للتطبيق على هاتف المستخدم فقط، وتشمل تلك البيانات:',
            isDark,
          ),
          _buildBulletItem('الاسم المستعار الاختياري', 'لتخصيص لوحة المتصدرين المحلية على الجهاز (مثل: "طالب علم").', isDark, primaryGold),
          _buildBulletItem('نقاط الخبرة المعرفية (XP)', 'لحساب المستوى والرتبة وتدرج الإتقان العلمي محلياً.', isDark, primaryGold),
          _buildBulletItem('قائمة الأسئلة المفضلة', 'الأسئلة التي يختار المستخدم حفظها للرجوع إليها ومراجعة توثيقها الشرعي.', isDark, primaryGold),
          _buildBulletItem('سجل الإجابات الخاطئة', 'لتمكين المستخدم من ميزة "مراجعة وتصحيح الأخطاء السابقة".', isDark, primaryGold),
          _buildBulletItem('الأوسمة المكتسبة', '12 وساماً إسلامياً تتوج بها مسيرتك العلمية محلياً.', isDark, primaryGold),
          _buildBulletItem('تفضيلات الواجهة', 'خيار تفعيل/كتم المؤثرات الصوتية والمظهر (الوضع الداكن / الوضع الفاتح).', isDark, primaryGold),
          _buildParagraph(
            'تنبيه تقني: هذه البيانات مُخزنة محلياً بنسبة 100% ولا تغادر جهاز المستخدم إلى أي خادم طرف ثالث أو سيرفر سحابي.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '٤',
        title: 'أذونات التطبيق وتبريرها البرمجي (Permissions)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('إذن الوصول للإنترنت', 'يُستخدم فقط للسماح بفتح روابط الدعم الخارجية عندما يطلب المستخدم ذلك صراحة (مثل فتح تطبيق واتساب للتواصل مع المطور لاقتراح سؤال أو نسخ ومشاركة الروابط). قاعدة الـ 1,000 سؤال بالكامل مدمجة محلياً ويعمل التطبيق 100% بدون اتصال.', isDark, primaryGold),
          _buildBulletItem('المؤثرات الصوتية (Audio Playback)', 'يستخدم التطبيق مشغل الصوت الداخلي لتشغيل نغمات التفاعل القصيرة. التطبيق لا يطلب ولا يستخدم إذن تسجيل الصوت أو الميكروفون على الإطلاق.', isDark, primaryGold),
          _buildBulletItem('انعدام الأذونات الحساسة', 'التطبيق لا يطلب أذونات الموقع الجغرافي، الكاميرا، الملفات، أو الأسماء.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '٥',
        title: 'سياسة خصوصية العائلة والأطفال (COPPA Compliance)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'يولي تطبيق «مَعارِف» حماية خصوصية الأطفال عناية فائقة، ويمتثل التزاماً تاماً لقانون حماية خصوصية الأطفال عبر الإنترنت (COPPA) والاشتراطات الصارمة لبرنامج العائلات في Google Play (Google Play Families Policy):',
            isDark,
          ),
          _buildBulletItem('محتوى تربوي نظيف', 'محتوى التطبيق ديني، ثقافي، نقي وخالٍ تماماً من أي محتوى مسيء أو عنيف لجميع الأعمار.', isDark, primaryGold),
          _buildBulletItem('عدم جمع بيانات الأطفال', 'لا يقوم التطبيق بجمع أو طلب أو تسجيل أي بيانات تخص الأطفال تحت أي ظرف.', isDark, primaryGold),
          _buildBulletItem('خالٍ من المشتريات والإعلانات', 'لا يتضمن التطبيق أي روابط شراء داخلية (In-App Purchases) ولا إعلانات سياقية.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '٦',
        title: 'خلو التطبيق التام من الإعلانات وشبكات التتبع التجاري',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('خالٍ تماماً من الإعلانات (100% Ad-Free)', 'لا يحتوي التطبيق على أي إعلانات بانر، أو بينية، أو إعلانات فيديو بمكافأة.', isDark, primaryGold),
          _buildBulletItem('انعدام أدوات التتبع الخارجية', 'لا نستخدم أي حزم برمجية لتحليل السلوك الإعلاني مثل: Google AdMob أو Facebook Pixel.', isDark, primaryGold),
          _buildBulletItem('لا مشاركة للبيانات مع وسطاء البيانات', 'لا يتم بيع أو تأجير أو مشاركة أي بيانات تخص استخدام التطبيق مع أي جهة تجارية.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '٧',
        title: 'المراسلة الطوعية عبر واتساب واقتراح الأسئلة',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'عند ضغط المستخدم على زر «إرسال الاقتراح عبر واتساب»، يقوم التطبيق بتجهيز نص الرسالة وتوجيهه برغبته الكاملة إلى تطبيق WhatsApp الرسمي للتواصل مع مطور المنصة (محمد كرم) على الرقم المعتمد: 01017325592.',
            isDark,
          ),
          _buildParagraph(
            'هذا الإجراء طوعي واختياري بنسبة 100%، ولا يتم إرسال أي رسالة تلقائياً بدون موافقة وضغط المستخدم المباشر داخل تطبيق واتساب.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '٨',
        title: 'أمان البيانات وحق الحذف الشامل (Data Deletion)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('الحق في الحذف الفوري', 'يمكنك مسح نقاطك وسجلك من خلال حذف الملف الشخصي أو مسح التخزين.', isDark, primaryGold),
          _buildBulletItem('الحذف عند إزالة التثبيت', 'بمجرد مسح التطبيق أو مسح بيانات التخزين من إعدادات جهازك، تُمسح كافة البيانات المخزنة محلياً نهائياً دون بقاء أي أثر.', isDark, primaryGold),
          _buildBulletItem('حماية البيئة المعزولة', 'أنظمة Android تؤمّن ملفات التخزين المحلي بحيث لا يمكن لأي تطبيق آخر الوصول إلى بيانات تطبيق «مَعارِف».', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '٩',
        title: 'التعديلات على سياسة الخصوصية',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'قد نقوم بتحديث سياسة الخصوصية من حين لآخر لتواكب أي متطلبات تنظيمية جديدة لمتجر Google Play أو إضافة مزايا تعليمية جديدة. سيتم دوماً نشر أحدث نسخة من هذه الوثيقة على الرابط الدائم المنشور على منصة GitHub Pages: https://mohamed249k.github.io/Ma3arf/privacy.html مع الإشارة الصريحة لتاريخ آخر مراجعة.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '١٠',
        title: 'بيانات التواصل الرسمية بمسؤول الخصوصية والمطور',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('المطور المسؤول', 'محمد كرم (Mohamed Karam)', isDark, primaryGold),
          _buildBulletItem('هاتف / واتساب', '01017325592 (دولي: +20 1017325592)', isDark, primaryGold),
          _buildBulletItem('الرابط العام المنشور', 'https://mohamed249k.github.io/Ma3arf/', isDark, primaryGold),
          _buildBulletItem('رابط سياسة الخصوصية الدائم', 'https://mohamed249k.github.io/Ma3arf/privacy.html', isDark, primaryGold),
        ],
      ),
    ];
  }

  List<Widget> _buildEnglishSections(
    Color cardBg,
    Color borderColor,
    Color primaryGold,
    bool isDark,
  ) {
    return [
      _buildSectionCard(
        number: '1',
        title: 'Introduction & Educational Endowment (Sadaqah Jariyah)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'Welcome to «Ma3arf | مَعارِف», an interactive Islamic educational platform dedicated to spreading authentic religious knowledge from the Noble Quran, Prophetic Sunnah, and Islamic civilization.',
            isDark,
          ),
          _buildParagraph(
            'This application is an educational endowment (Sadaqah Jariyah) developed by Mohamed Karam purely for the sake of Allah, without any commercial or profit-making motives.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '2',
        title: 'Zero Personal Data Collection Policy',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'Under Islamic principles and Google Play Developer Policies, Ma3arf does NOT collect, request, record, store remotely, share, or sell any Personally Identifiable Information (PII) whatsoever.',
            isDark,
          ),
          _buildBulletItem('No Real Identity / Names', 'No registration, national ID, or full name required.', isDark, primaryGold),
          _buildBulletItem('No Email or Passwords', 'No online authentication or cloud login system.', isDark, primaryGold),
          _buildBulletItem('No Phone / Contacts', 'The app never requests access to your address book.', isDark, primaryGold),
          _buildBulletItem('No Geolocation (GPS)', 'The app does not track or request your location.', isDark, primaryGold),
          _buildBulletItem('No Advertising ID (GAID)', 'Completely devoid of ad-tracking libraries.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '3',
        title: 'Purely Local Storage (Offline-First Architecture)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'Ma3arf relies entirely on sandboxed local storage (SharedPreferences) on your physical Android device. Stored items include:',
            isDark,
          ),
          _buildBulletItem('Optional Alias', 'Used strictly for local leaderboard display.', isDark, primaryGold),
          _buildBulletItem('Experience Points (XP)', 'Tracks your learning progress and knowledge levels locally.', isDark, primaryGold),
          _buildBulletItem('Favorites & Mistakes', 'Bookmarked questions and incorrect answers saved for personal revision.', isDark, primaryGold),
          _buildBulletItem('Badges & Audio State', '12 Islamic achievement badges and mute/unmute preferences.', isDark, primaryGold),
          _buildParagraph(
            'Technical Guarantee: 100% of this data stays on your phone and is never sent to any remote server or cloud database.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '4',
        title: 'App Permissions & Software Justification',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('Internet Access', 'Used strictly when the user voluntarily taps external developer contact links (WhatsApp feedback) or shares challenge codes.', isDark, primaryGold),
          _buildBulletItem('Audio Playback', 'Plays short offline chime feedback. The app NEVER requests or uses microphone or audio recording permissions.', isDark, primaryGold),
          _buildBulletItem('Zero Sensitive Permissions', 'No camera, contacts, files, or Bluetooth permissions requested.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '5',
        title: 'Children & Family Safety (COPPA Compliance)',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'Ma3arf is suitable for all ages and strictly complies with the Google Play Families Policy and the Children’s Online Privacy Protection Act (COPPA):',
            isDark,
          ),
          _buildBulletItem('Clean Educational Content', 'Pure religious and moral content suitable for homes and schools.', isDark, primaryGold),
          _buildBulletItem('Zero Data on Children', 'We never collect or process any personal data from children.', isDark, primaryGold),
          _buildBulletItem('Zero Purchases / Zero Ads', 'No in-app purchases and no commercial advertisements.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '6',
        title: '100% Ad-Free & Telemetry-Free Guarantee',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('No Commercial Ads', 'No banner, interstitial, or rewarded video ads.', isDark, primaryGold),
          _buildBulletItem('No Third-Party Trackers', 'No Google AdMob, Facebook Pixel, Adjust, or AppsFlyer SDKs.', isDark, primaryGold),
          _buildBulletItem('No Data Brokers', 'No user data is ever sold, leased, or shared.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '7',
        title: 'Voluntary WhatsApp Communication',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'When tapping "Send Suggestion via WhatsApp", the app prepares the message text and forwards it only upon explicit user action to WhatsApp to contact Mohamed Karam (+20 1017325592). This is 100% voluntary.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '8',
        title: 'Data Security & Right to Deletion',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('Immediate Data Reset', 'Users can reset scores and streaks at any time inside the app.', isDark, primaryGold),
          _buildBulletItem('Complete Purge on Uninstall', 'Clearing storage or uninstalling the app permanently erases all local data.', isDark, primaryGold),
          _buildBulletItem('Sandbox Security', 'Android OS sandboxing prevents other applications from accessing Ma3arf data.', isDark, primaryGold),
        ],
      ),
      _buildSectionCard(
        number: '9',
        title: 'Policy Updates',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildParagraph(
            'This policy may be updated periodically to match new Google Play regulatory requirements. The latest version will always be maintained at: https://mohamed249k.github.io/Ma3arf/privacy.html.',
            isDark,
          ),
        ],
      ),
      _buildSectionCard(
        number: '10',
        title: 'Official Contact Information',
        cardBg: cardBg,
        borderColor: borderColor,
        primaryGold: primaryGold,
        isDark: isDark,
        children: [
          _buildBulletItem('Lead Developer', 'Mohamed Karam', isDark, primaryGold),
          _buildBulletItem('WhatsApp', '+20 101 732 5592 (01017325592)', isDark, primaryGold),
          _buildBulletItem('Official Website', 'https://mohamed249k.github.io/Ma3arf/', isDark, primaryGold),
          _buildBulletItem('Permanent Policy URL', 'https://mohamed249k.github.io/Ma3arf/privacy.html', isDark, primaryGold),
        ],
      ),
    ];
  }
}
