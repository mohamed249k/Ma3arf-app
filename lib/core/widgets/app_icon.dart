import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';

/// Reusable centralized icon widget for the Ma3arf Islamic Learning platform.
/// Seamlessly handles:
/// - Phosphor Duotone vector icons (with subtle secondary layer opacity)
/// - FontAwesome authentic Islamic icons (Mosque, Kaaba, Quran)
/// - Standard Flutter IconData
/// - Theme-aware color defaults and RTL text direction mirroring
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final double duotoneSecondaryOpacity;
  final String? semanticLabel;
  final bool matchTextDirection;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.duotoneSecondaryOpacity = 0.25,
    this.semanticLabel,
    this.matchTextDirection = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final effectiveColor =
        color ?? appColors?.primary ?? theme.colorScheme.primary;
    final effectiveSize = size ?? AppIconSize.medium;

    Widget renderedIcon;

    if (icon is PhosphorIconData) {
      renderedIcon = PhosphorIcon(
        icon as PhosphorIconData,
        size: effectiveSize,
        color: effectiveColor,
        duotoneSecondaryOpacity: duotoneSecondaryOpacity,
        semanticLabel: semanticLabel,
      );
    } else if (icon.fontPackage == 'font_awesome_flutter') {
      renderedIcon = FaIcon(
        FaIconData(icon),
        size: effectiveSize,
        color: effectiveColor,
        semanticLabel: semanticLabel,
      );
    } else {
      renderedIcon = Icon(
        icon,
        size: effectiveSize,
        color: effectiveColor,
        semanticLabel: semanticLabel,
      );
    }

    if (matchTextDirection) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      if (isRtl) {
        return Transform.scale(
          scaleX: -1.0,
          alignment: Alignment.center,
          child: renderedIcon,
        );
      }
    }

    return renderedIcon;
  }
}

/// Standardized container for icons throughout Ma3arf.
/// Provides consistent rounded or circular badges, subtle background tints,
/// and luxury border accents adhering to the modern Islamic editorial direction.
class AppIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final double duotoneSecondaryOpacity;
  final VoidCallback? onTap;

  const AppIconContainer({
    super.key,
    required this.icon,
    this.size = 44.0,
    this.iconSize,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.isCircle = true,
    this.duotoneSecondaryOpacity = 0.25,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final effectiveIconColor = iconColor ?? appColors?.gold ?? AppGold.rich;
    final effectiveBgColor =
        backgroundColor ?? effectiveIconColor.withValues(alpha: 0.12);
    final effectiveBorderColor =
        borderColor ?? effectiveIconColor.withValues(alpha: 0.25);
    final effectiveRadius = isCircle
        ? null
        : (borderRadius ?? BorderRadius.circular(12.0));

    Widget container = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1.2),
      ),
      child: AppIcon(
        icon,
        size: iconSize ?? (size * 0.52),
        color: effectiveIconColor,
        duotoneSecondaryOpacity: duotoneSecondaryOpacity,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        shape: isCircle ? const CircleBorder() : null,
        borderRadius: isCircle ? null : effectiveRadius,
        child: InkWell(
          onTap: onTap,
          customBorder: isCircle ? const CircleBorder() : null,
          borderRadius: isCircle ? null : effectiveRadius,
          child: container,
        ),
      );
    }

    return container;
  }
}
