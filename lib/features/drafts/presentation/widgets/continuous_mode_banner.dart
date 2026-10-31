import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class ContinuousModeBanner extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const ContinuousModeBanner({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isEnabled
            ? BaloraColors.primarySoft
            : BaloraColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? BaloraColors.primary.withValues(alpha: 0.35)
              : BaloraColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isEnabled
                  ? BaloraColors.primary
                  : BaloraColors.textMuted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 20,
              color: isEnabled ? Colors.white : BaloraColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'نمط الإالمتتابع',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? BaloraColors.primaryDark
                            : BaloraColors.textPrimary,
                      ),
                    ),
                    if (isEnabled) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BaloraColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'نشط',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isEnabled
                      ? 'عند الحفظ، يُفرّغ النموذج وتُفتح الكاميرا فوراً للصنف التالي'
                      : 'حفظ مسودة واحدة والعودة للقائمة',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isEnabled
                        ? BaloraColors.primaryDark.withValues(alpha: 0.8)
                        : BaloraColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeTrackColor: BaloraColors.primaryLight,
              activeThumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
