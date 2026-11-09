import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static const String projectUrl = 'https://mohamed249k.github.io/Ma3arf/';

  /// Generates a motivational and clean Arabic challenge message with reproducible question IDs
  static String generateShareText({
    required int score,
    required int totalQuestions,
    required int percent,
    required String difficultyName,
    required String category,
    required String quizModeName,
    List<int>? questionIds,
  }) {
    final challengeQuery = (questionIds != null && questionIds.isNotEmpty)
        ? '?challenge=1&qids=${questionIds.join(",")}'
        : '';
    final codeLine = (questionIds != null && questionIds.isNotEmpty)
        ? '\n🎯 كود التحدي الموحد: MA3ARF-${questionIds.join("-")}\n'
        : '';

    return '''
أحرزت $score من $totalQuestions ($percent%) في منصة مَعارِف | Ma3arf!
المستوى: $difficultyName • التصنيف: $category • النمط: $quizModeName
$codeLine
تعلّم معلومة إسلامية موثوقة وجديدة وتحدّاني في نفس الأسئلة تماماً!
خض التحدي المباشر الآن:
$projectUrl$challengeQuery

(وقفٌ لله تعالى وصدقة جارية لنشر العلم النافع)
'''
        .trim();
  }

  /// Copies text to clipboard with feedback
  static Future<bool> copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ نص النتيجة ورسالة التحدي بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Direct WhatsApp share with safe fallback
  static Future<bool> shareToWhatsApp(BuildContext context, String text) async {
    final encoded = Uri.encodeComponent(text);
    final appUri = Uri.parse('whatsapp://send?text=$encoded');
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return true;
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to clipboard
        if (context.mounted) {
          await copyToClipboard(context, text);
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تعذر فتح تطبيق واتساب، تم نسخ رسالة التحدي لمشاركتها يدوياً',
              ),
            ),
          );
        }
        return false;
      }
    } catch (_) {
      if (context.mounted) {
        await copyToClipboard(context, text);
      }
      return false;
    }
  }

  /// Native OS share sheet via share_plus with mailto/clipboard fallback
  static Future<bool> shareGeneral(BuildContext context, String text) async {
    try {
      // ignore: deprecated_member_use
      final result = await Share.share(
        text,
        subject: 'تحدي مَعارِف | Ma3arf الإسلامي',
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      // Fallback to mailto
      final encoded = Uri.encodeComponent(text);
      final subject = Uri.encodeComponent('تحدي مَعارِف | Ma3arf الإسلامي');
      final mailUri = Uri.parse('mailto:?subject=$subject&body=$encoded');

      try {
        if (await canLaunchUrl(mailUri)) {
          await launchUrl(mailUri);
          return true;
        } else if (context.mounted) {
          return await copyToClipboard(context, text);
        }
      } catch (_) {
        if (context.mounted) {
          return await copyToClipboard(context, text);
        }
      }
      return false;
    }
  }

  /// Renders a RepaintBoundary widget into PNG bytes
  static Future<Uint8List?> captureWidgetToImage(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Shares the generated result image card and text via native OS share sheet
  static Future<bool> shareImageAndText({
    required BuildContext context,
    required GlobalKey cardKey,
    required String text,
  }) async {
    try {
      final bytes = await captureWidgetToImage(cardKey);
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/ma3arf_card_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(bytes);
        // ignore: deprecated_member_use
        final result = await Share.shareXFiles(
          [XFile(file.path)],
          text: text,
          subject: 'نتيجة تحدي مَعارِف | Ma3arf',
        );
        return result.status == ShareResultStatus.success;
      }
    } catch (_) {}

    // Fallback to text sharing if image rendering or saving fails
    if (context.mounted) {
      return await shareGeneral(context, text);
    }
    return false;
  }
}
