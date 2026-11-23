import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// Shown instead of a server-dependent screen when the device is not
/// linked to a Balora Desktop (guest mode). Explains what is missing
/// and offers the link action — it never navigates away on its own.
class LinkRequiredView extends StatelessWidget {
  const LinkRequiredView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BaloraColors.warningSoft,
                shape: BoxShape.circle,
                border: Border.all(color: BaloraColors.warningBorder),
              ),
              child: const Icon(
                Icons.link_off_rounded,
                color: BaloraColors.warning,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هذه الميزة تحتاج الربط بالكمبيوتر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: BaloraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'اربط هاتفك بنظام Balora للكمبيوتر لتفعيل هذه الميزة. '
                      'الربط يتم مرة واحدة من الإعدادات أو من الرئيسية.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: BaloraColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/pairing'),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(
                'ربط مع الدسكتوب',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BaloraColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
