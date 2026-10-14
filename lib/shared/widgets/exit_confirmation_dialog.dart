import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// يعرض مربع حوار لتأكيد الخروج من التطبيق.
///
/// يُرجع `true` إذا اختار المستخدم الخروج، و`false` إذا ألغى العملية.
Future<bool> showExitConfirmationDialog(
  BuildContext context, {
  int pendingCount = 0,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BaloraColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.exit_to_app_rounded,
              color: BaloraColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'الخروج من التطبيق',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'هل أنت متأكد من رغبتك في إغلاق التطبيق؟',
            style: TextStyle(
              fontSize: 14,
              color: BaloraColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (pendingCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BaloraColors.warningSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: BaloraColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: BaloraColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تنبيه: لديك $pendingCount عناصر جرد قيد الانتظار لم تُرسل بعد.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BaloraColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: BaloraColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('خروج'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
