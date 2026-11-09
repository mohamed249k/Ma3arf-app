import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/features/privacy/privacy_policy_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Authentic Islamic Charity Footer for Ma3arf
/// Matches the reference website:
/// 1. Islamic ornamental divider
/// 2. Sadaqah Jariyah dedication card
/// 3. Share invitation box with authentic Hadith («الدَّالُّ عَلَى الخَيْرِ كَفَاعِلِهِ»)
/// 4. Official credits to Mohamed Karam, direct WhatsApp link, and copyright
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const String webUrl = 'https://mohamed249k.github.io/Ma3arf/';
  static const String developerWhatsAppPhone = '201017325592';
  static const String developerWhatsAppDisplay = '01017325592';
  static const String developerName = 'محمد كرم (Mohamed Karam)';

  Future<void> _shareApp(BuildContext context) async {
    AudioFeedbackService.instance.playClick();
    const shareText =
        'منصة «مَعارِف» للتعليم والمسابقات الإسلامية — وقف لله تعالى وصدقة جارية 🌱\n'
        'تطبيق متكامل يضم 1,000 سؤال موثق من القرآن والحديث والسيرة النبوية.\n'
        'جرّب المنصة وشاركنا في نشر العلم النافع:\n$webUrl';

    try {
      // ignore: deprecated_member_use
      await Share.share(shareText, subject: 'منصة مَعارِف للتعليم الإسلامي');
    } catch (_) {
      // Fallback: Copy to clipboard
      await Clipboard.setData(const ClipboardData(text: shareText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ نص ورابط المشاركة بنجاح 📋'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    AudioFeedbackService.instance.playClick();
    await Clipboard.setData(const ClipboardData(text: webUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رابط منصة مَعارِف بنجاح 📋'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _contactDeveloperWhatsApp(BuildContext context) async {
    AudioFeedbackService.instance.playClick();
    const greeting =
        'السلام عليكم ورحمة الله وبركاته يا أستاذ محمد كرم،\n'
        'أتواصل معك بخصوص منصة «مَعارِف» للتعليم الإسلامي:';
    final deepLink = Uri.parse(
      'whatsapp://send?phone=$developerWhatsAppPhone&text=${Uri.encodeComponent(greeting)}',
    );
    final webLink = Uri.parse(
      'https://api.whatsapp.com/send?phone=$developerWhatsAppPhone&text=${Uri.encodeComponent(greeting)}',
    );

    try {
      if (await canLaunchUrl(deepLink)) {
        await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webLink)) {
        await launchUrl(webLink, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Copy phone number to clipboard
        await Clipboard.setData(const ClipboardData(text: developerWhatsAppDisplay));
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
      await Clipboard.setData(const ClipboardData(text: developerWhatsAppDisplay));
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

    const goldColor = Color(0xFFD7B56D);
    final cardBg = isDark ? const Color(0xFF132F24) : const Color(0xFFF3EEE4);
    final cardBorder = isDark ? const Color(0xFF244838) : const Color(0xFFE2D6C3);
    final subtleText = isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65);
    final bodyText = isDark ? const Color(0xFFE8ECE9) : const Color(0xFF2C3E35);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF091611) : const Color(0xFFEFE8DB),
        border: Border(
          top: BorderSide(
            color: goldColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Decorative Islamic Ornament
          CustomPaint(
            size: const Size(140, 24),
            painter: _IslamicOrnamentPainter(goldColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),

          // 2. Sadaqah Jariyah Dedication Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    AppIcons.beginner,
                    color: goldColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وقفٌ لله تعالى وصدقة جارية',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'هذا العمل وقفٌ تعليمي لوجه الله تبارك وتعالى، صُمِّم ابتغاء مرضاته ولخدمة العلوم الشرعية وتثبيت معارف القرآن الكريم والسنة النبوية الشريفة. نسأل الله العظيم أن يجعله صدقةً جارية عنّا وعن والدينا وعن جميع المسلمين والمسلمات الأحياء منهم والأموات.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bodyText,
                          fontSize: 12.5,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Sharing Invitation Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: goldColor.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hadith quote pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '«الدَّالُّ عَلَى الخَيْرِ كَفَاعِلِهِ»',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: goldColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(رواه الإمام مسلم)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtleText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Appeal text
                Text(
                  'أخي الكريم، أختي الكريمة: إذا وصلك هذا التطبيق ووجدت فيه خيراً ونفعاً، فساهم مشكوراً في مشاركته مع أهلك وأصحابك لنشارك جميعاً في الأجر والثواب ونشر العلم النافع؛ فرُبَّ مُبلَّغٍ أوعى من سامع.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: bodyText,
                    fontSize: 13,
                    height: 1.65,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _shareApp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: const Color(0xFF0F261E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(
                            AppIcons.share,
                            size: 19,
                            color: const Color(0xFF0F261E),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'مشاركة التطبيق واحتساب الأجر',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => _copyLink(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF0F261E),
                      side: BorderSide(
                        color: goldColor.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          AppIcons.copy,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF0F261E),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'نسخ الرابط',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Copyright and Developer Credits
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    'فكرة وإعداد وتطوير:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtleText,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    developerName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // WhatsApp contact badge
              FittedBox(
                fit: BoxFit.scaleDown,
                child: InkWell(
                  onTap: () => _contactDeveloperWhatsApp(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF25D366).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.whatsappFill,
                          size: 16,
                          color: const Color(0xFF25D366),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'واتساب: $developerWhatsAppDisplay',
                          style: TextStyle(
                            color: Color(0xFF25D366),
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Privacy Policy Link Button
              InkWell(
                onTap: () {
                  AudioFeedbackService.instance.playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        AppIcons.shieldCheck,
                        size: 14,
                        color: goldColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'سياسة الخصوصية وحماية البيانات',
                          style: TextStyle(
                            color: goldColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '— صدقة جارية ومتاح لكل مسلم ومسلمة للنشر والتعلم',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtleText,
                  fontSize: 11.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              Text(
                'منصة معارف | Ma3arf © 2026 — تقبل الله منا ومنكم صالح الأعمال',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtleText.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IslamicOrnamentPainter extends CustomPainter {
  final Color color;
  _IslamicOrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Curved ornamental wave: M0,size.height/2 Qsize.width*0.25,0 size.width*0.5,size.height/2 Qsize.width*0.75,size.height size.width,size.height/2
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
    // Center jewel
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 3.2, dotPaint);
    // Side accents
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.35), 1.6, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.65), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicOrnamentPainter oldDelegate) =>
      color != oldDelegate.color;
}
