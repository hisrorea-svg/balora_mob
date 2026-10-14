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
          title: const Text('Balora Mobile'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: BaloraColors.border),
          ),
          actions: const [
            _ConnectionChip(),
            SizedBox(width: 4),
            _SettingsButton(),
            SizedBox(width: 4),
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
                        // --- Section 1: Primary Live Scanning ---
                        const _SectionTitle('المسح الفوري'),
                        const SizedBox(height: 10),
                        _PrimaryHeroActionCard(
                          title: 'ماسح الكاشير المباشر',
                          subtitle:
                              'إرسال الباركود فوراً إلى فاتورة البيع المفتوحة على الكمبيوتر',
                          icon: Icons.qr_code_scanner_rounded,
                          onTap: () {
                            ref
                                .read(scannerModeNotifierProvider.notifier)
                                .set(ScannerMode.sale);
                            context.push('/scan');
                          },
                        ),
                        const SizedBox(height: 10),
                        _SecondaryActionRowCard(
                          title: 'فحص السعر والرصيد',
                          subtitle:
                              'استعلام سريع عن سعر المنتج بالدينار والكمية المتوفرة',
                          icon: Icons.manage_search_rounded,
                          onTap: () {
                            ref
                                .read(scannerModeNotifierProvider.notifier)
                                .set(ScannerMode.search);
                            context.push('/scan');
                          },
                        ),

                        const SizedBox(height: 22),

                        // --- Section 2: Warehouse & Inventory Operations ---
                        const _SectionTitle('المخزن والجرد'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _CompactGridCard(
                                title: 'جرد المخزون',
                                subtitle: 'عدّ الأصناف الميداني',
                                icon: Icons.inventory_2_outlined,
                                onTap: () {
                                  ref
                                      .read(
                                        scannerModeNotifierProvider.notifier,
                                      )
                                      .set(ScannerMode.inventory);
                                  context.push('/scan');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CompactGridCard(
                                title: 'استلام بضاعة',
                                subtitle: 'تسجيل الوارد للمخزن',
                                icon: Icons.move_to_inbox_outlined,
                                onTap: () {
                                  ref
                                      .read(
                                        scannerModeNotifierProvider.notifier,
                                      )
                                      .set(ScannerMode.receiving);
                                  context.push('/scan');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _SecondaryActionRowCard(
                          title: 'العمليات المعلقة والمزامنة',
                          subtitle: pendingCount > 0
                              ? 'توجد $pendingCount عملية بانتظار المزامنة مع الكمبيوتر'
                              : 'جميع عمليات الجرد والاستلام متزامنة',
                          icon: Icons.sync_rounded,
                          badgeCount: pendingCount,
                          onTap: () => context.push('/inventory/review'),
                        ),

                        const SizedBox(height: 22),

                        // --- Section 3: Catalog Management ---
                        const _SectionTitle('إدارة الأصناف'),
                        const SizedBox(height: 10),
                        _SecondaryActionRowCard(
                          title: 'إضافة منتج جديد يدوياً',
                          subtitle:
                              'تعريف صنف جديد وإرساله لقاعدة بيانات الصيدلية',
                          icon: Icons.add_box_outlined,
                          onTap: () => context.push('/products/add'),
                        ),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: BaloraColors.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Primary hero card for the main high-frequency POS scanner workflow.
class _PrimaryHeroActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryHeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaloraColors.primary,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean horizontal row card for structured secondary actions.
class _SecondaryActionRowCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _SecondaryActionRowCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: BaloraColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: BaloraColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: BaloraColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: BaloraColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: BaloraColors.warningSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: BaloraColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: BaloraColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact 2-column card that adapts height to content without fixed aspect-ratio overflow.
class _CompactGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: BaloraColors.primarySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: BaloraColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
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
                  fontSize: 12,
                  color: BaloraColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill chip showing the verified connection state, matching Balora Desktop's `.chip.ok` / `.chip.bad`.
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
              decoration: BoxDecoration(color: fgColor, shape: BoxShape.circle),
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
    );
  }
}
