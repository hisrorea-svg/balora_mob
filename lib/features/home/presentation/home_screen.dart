import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/exit_confirmation_dialog.dart';
import '../../inventory/presentation/inventory_providers.dart';
import '../../scanner/domain/scanner_mode.dart';
import '../../scanner/presentation/scanner_mode_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingInventoryItemsProvider);
    final pendingCount = pendingAsync.value?.length ?? 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
          return;
        }
        final shouldExit = await showExitConfirmationDialog(
          context,
          pendingCount: pendingCount,
        );
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/balora_logo.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: BaloraColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      color: BaloraColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Balora',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: BaloraColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    'نظام إدارة الصيدليات',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: BaloraColors.textMuted,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: BaloraColors.borderSubtle),
          ),
          actions: const [
            _ConnectionChip(),
            SizedBox(width: 6),
            _SettingsButton(),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final horizontalPad = isCompact ? 12.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Hero Card: POS Live Barcode Scanner ---
                        _PosHeroScannerCard(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(scannerModeNotifierProvider.notifier)
                                .set(ScannerMode.sale);
                            context.push('/scan');
                          },
                        ),

                        const SizedBox(height: 22),

                        // --- Section Title: Operations Grid ---
                        Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 14,
                              decoration: BoxDecoration(
                                color: BaloraColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'العمليات الميدانية',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: BaloraColors.textSecondary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // --- 2x2 Operations Grid ---
                        Row(
                          children: [
                            Expanded(
                              child: _OperationGridCard(
                                title: 'فحص السعر',
                                subtitle: 'الاستعلام عن السعر والرصيد',
                                icon: Icons.search_rounded,
                                iconBg: BaloraColors.primarySoft,
                                iconFg: BaloraColors.primary,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(
                                        scannerModeNotifierProvider.notifier,
                                      )
                                      .set(ScannerMode.search);
                                  context.push('/scan');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OperationGridCard(
                                title: 'جرد المخزون',
                                subtitle: 'عدّ وتدقيق أصناف الرف',
                                icon: Icons.inventory_2_outlined,
                                iconBg: BaloraColors.successSoft,
                                iconFg: BaloraColors.success,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(
                                        scannerModeNotifierProvider.notifier,
                                      )
                                      .set(ScannerMode.inventory);
                                  context.push('/scan');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _OperationGridCard(
                                title: 'استلام بضاعة',
                                subtitle: 'تسجيل الوارد للمخزن',
                                icon: Icons.move_to_inbox_rounded,
                                iconBg: BaloraColors.infoSoft,
                                iconFg: BaloraColors.info,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(
                                        scannerModeNotifierProvider.notifier,
                                      )
                                      .set(ScannerMode.receiving);
                                  context.push('/scan');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OperationGridCard(
                                title: 'إضافة صنف',
                                subtitle: 'تعريف دواء أو مادة جديدة',
                                icon: Icons.add_box_outlined,
                                iconBg: BaloraColors.warningSoft,
                                iconFg: BaloraColors.warning,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push('/products/add');
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // --- Section Title: Sync & System Status ---
                        Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 14,
                              decoration: BoxDecoration(
                                color: pendingCount > 0
                                    ? BaloraColors.warning
                                    : BaloraColors.success,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'حالة المزامنة والربط',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: BaloraColors.textSecondary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // --- Live Sync & Health Card ---
                        _SyncHealthCard(
                          pendingCount: pendingCount,
                          onReviewTap: () => context.push('/inventory/review'),
                        ),

                        const SizedBox(height: 28),

                        // --- Subdued Brand Footer ---
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Balora Companion',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: BaloraColors.textMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  '•',
                                  style: TextStyle(
                                    color: BaloraColors.textMuted.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text(
                                'الإصدار 1.0.7',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: BaloraColors.textMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Primary Hero Action Card: Styled with Balora Clinical Deep Teal gradient.
class _PosHeroScannerCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PosHeroScannerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BaloraColors.primary, BaloraColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BaloraColors.primaryDark.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: BaloraColors.tealMint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'نقطة البيع المباشرة • POS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Main Info Row
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'قارئ باركود الكاشير',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إرسال فوري إلى فاتورة البيع المفتوحة بالكمبيوتر',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Pill / Quick Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'اضغط هنا لبدء المسح الفوري',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'فتح الكاميرا',
                            style: TextStyle(
                              color: BaloraColors.tealMint,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: BaloraColors.tealMint,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Structured 2x2 Operations Grid Card matching Desktop Tile aesthetic.
class _OperationGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final VoidCallback onTap;

  const _OperationGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaloraColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BaloraColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconFg, size: 22),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: BaloraColors.textMuted.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: BaloraColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: BaloraColors.textMuted,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sync status and offline items health card.
class _SyncHealthCard extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onReviewTap;

  const _SyncHealthCard({
    required this.pendingCount,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPending = pendingCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: BaloraColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPending
              ? BaloraColors.warningBorder
              : BaloraColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onReviewTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasPending
                        ? BaloraColors.warningSoft
                        : BaloraColors.successSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasPending
                        ? Icons.sync_problem_rounded
                        : Icons.check_circle_outline_rounded,
                    color: hasPending
                        ? BaloraColors.warning
                        : BaloraColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasPending
                            ? 'توجد $pendingCount عمليات معلقة'
                            : 'المزامنة مكتملة',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: hasPending
                              ? BaloraColors.warning
                              : BaloraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasPending
                            ? 'اضغط للمراجعة والإرسال الفوري للكمبيوتر'
                            : 'جميع عمليات الجرد والاستلام مطابقة مع السيرفر',
                        style: const TextStyle(
                          fontSize: 12,
                          color: BaloraColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (hasPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: BaloraColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'مزامنة',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.cloud_done_rounded,
                    color: BaloraColors.success.withValues(alpha: 0.8),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Connection pill chip matching Balora Desktop's `.server-status.connected` indicator.
class _ConnectionChip extends ConsumerWidget {
  const _ConnectionChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked = ref.watch(connectionStateProvider);
    final bgColor = linked ? BaloraColors.successSoft : BaloraColors.errorSoft;
    final fgColor = linked ? BaloraColors.success : BaloraColors.error;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fgColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: fgColor,
                shape: BoxShape.circle,
                boxShadow: linked
                    ? [
                        BoxShadow(
                          color: fgColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              linked ? 'متصل' : 'غير متصل',
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => context.push('/settings'),
      tooltip: 'الإعدادات',
      color: BaloraColors.textSecondary,
    );
  }
}
