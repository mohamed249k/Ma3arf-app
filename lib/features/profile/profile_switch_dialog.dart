import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';

class ProfileSwitchDialog extends StatefulWidget {
  final GameState gameState;

  const ProfileSwitchDialog({super.key, required this.gameState});

  static void show(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => ProfileSwitchDialog(gameState: gameState),
    );
  }

  @override
  State<ProfileSwitchDialog> createState() => _ProfileSwitchDialogState();
}

class _ProfileSwitchDialogState extends State<ProfileSwitchDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddProfileDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة ملف شخصي جديد'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم المستخدم (مثال: أحمد، فاطمة...)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            child: const Text('إضافة'),
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogCtx).pop();
                await widget.gameState.createProfile(name);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(UserProfile p) {
    _nameController.text = p.displayName;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('تعديل اسم الملف الشخصي'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'الاسم الجديد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.of(dialogCtx).pop();
                await widget.gameState.renameProfile(p.id, newName);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(UserProfile p) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('تأكيد حذف الملف الشخصي'),
        content: Text(
          'هل أنت متأكد من حذف الملف الشخصي "${p.displayName}"؟ سيتم حذف بياناته من هذا الجهاز.',
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف'),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await widget.gameState.deleteProfile(p.id);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gs = widget.gameState;
    final profiles = gs.localProfiles;
    final currentId = gs.profile.id;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppIcon(
                    AppIcons.profile,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الملفات الشخصية المحلية',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تبديل الحساب أو مشاركة الجهاز مع العائلة',
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
            const SizedBox(height: 14),

            // Profiles List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final p = profiles[i];
                  final isCurrent = p.id == currentId;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.colorScheme.primary.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            )
                          : (isDark ? const Color(0xFF13221C) : null),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.secondary
                            : theme.dividerColor.withValues(alpha: 0.3),
                        width: isCurrent ? 1.6 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? theme.colorScheme.secondary
                            : theme.dividerColor.withValues(alpha: 0.3),
                        child: p.displayName.isNotEmpty
                            ? Text(
                                p.displayName[0],
                                style: TextStyle(
                                  color: isCurrent ? Colors.black : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : AppIcon(
                                AppIcons.profile,
                                size: 18,
                                color: isCurrent ? Colors.black : null,
                              ),
                      ),
                      title: Text(
                        p.displayName,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isCurrent ? theme.colorScheme.secondary : null,
                        ),
                      ),
                      subtitle: Text(
                        '${p.totalXp} XP • ${p.totalQuizzes} اختبار',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: AppIcon(AppIcons.edit, size: 18),
                            tooltip: 'تعديل الاسم',
                            onPressed: () => _showRenameDialog(p),
                          ),
                          if (profiles.length > 1 && !isCurrent)
                            IconButton(
                              icon: AppIcon(AppIcons.delete, size: 18),
                              tooltip: 'حذف',
                              onPressed: () => _confirmDeleteProfile(p),
                            ),
                          if (isCurrent)
                            AppIcon(
                              AppIcons.checkCircle,
                              color: const Color(0xFF2E8B68),
                              size: 20,
                            ),
                        ],
                      ),
                      onTap: () async {
                        if (!isCurrent) {
                          await gs.switchProfile(p.id);
                          setState(() {});
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Add Profile Button
            OutlinedButton.icon(
              icon: AppIcon(AppIcons.userAdd, size: 18),
              label: const Text('إضافة ملف شخصي جديد'),
              onPressed: _showAddProfileDialog,
            ),
          ],
        ),
      ),
    );
  }
}
