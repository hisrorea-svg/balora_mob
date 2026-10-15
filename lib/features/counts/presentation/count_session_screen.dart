import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/sync/database/app_database.dart';
import '../../inventory/presentation/inventory_providers.dart';
import '../../scanner/presentation/widgets/barcode_scanner_dialog.dart';
import '../domain/count_models.dart';
import 'count_session_controller.dart';
import 'count_session_state.dart';
import 'widgets/batch_picker_sheet.dart';
import 'widgets/manual_quantity_sheet.dart';

/// Live counting screen for one open draft: scan or type a barcode, adjust a
/// line manually, and watch the server-confirmed counters move.
class CountSessionScreen extends ConsumerStatefulWidget {
  const CountSessionScreen({super.key, required this.count});

  final ActiveCount count;

  @override
  ConsumerState<CountSessionScreen> createState() => _CountSessionScreenState();
}

class _CountSessionScreenState extends ConsumerState<CountSessionScreen> {
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocus = FocusNode();

  CountSession get _notifier =>
      ref.read(countSessionProvider(widget.count.id).notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(_notifier.refresh);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  void _submitTypedBarcode() {
    final barcode = _scanController.text.trim();
    if (barcode.isEmpty) return;
    _scanController.clear();
    _notifier.submitScan(barcode);
    _scanFocus.requestFocus();
  }

  Future<void> _scanWithCamera() async {
    final code = await showBarcodeScannerDialog(context);
    if (code == null || code.isEmpty || !mounted) return;
    await _notifier.submitScan(code);
  }

  Future<void> _editLine(CountLine line) async {
    final result = await showModalBottomSheet<ManualQuantity>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ManualQuantitySheet(line: line),
    );
    if (result == null || !mounted) return;
    await _notifier.submitSet(
      lineId: line.lineId,
      packages: result.packages,
      looseUnits: result.looseUnits,
    );
  }

  Future<void> _showBatchPicker(BatchSelectionRequest request) async {
    final option = await showModalBottomSheet<CountBatchOption>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BatchPickerSheet(request: request),
    );
    if (!mounted) return;
    if (option == null) {
      _notifier.dismissBatchSelection();
    } else {
      _notifier.resolveBatchSelection(option);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = countSessionProvider(widget.count.id);

    ref.listen(provider, (previous, next) {
      if (next.feedback != null && next.feedback != previous?.feedback) {
        if (next.feedbackIsError) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      }
      if (next.batchSelection != null && previous?.batchSelection == null) {
        _showBatchPicker(next.batchSelection!);
      }
    });

    // The offline banner follows the real queue: it appears while commands for
    // this count wait locally and disappears as soon as the sync engine drains
    // them; the drain also reconciles the screen with the server.
    final pendingAsync = ref.watch(pendingCountCommandsProvider);
    final queuedCount = _queuedForCount(pendingAsync.value);
    ref.listen(pendingCountCommandsProvider, (previous, next) {
      final before = _queuedForCount(previous?.value);
      final after = _queuedForCount(next.value);
      if (before > 0 && after == 0) {
        _notifier.refresh();
      }
    });

    final session = ref.watch(provider);
    final snapshot = session.snapshot;
    final canCount = snapshot?.isDraft ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جرد — ${snapshot?.locationName.isNotEmpty == true ? snapshot!.locationName : widget.count.locationName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () => _notifier.refresh(),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(session, canCount, queuedCount)),
    );
  }

  int _queuedForCount(List<QueueItemEntry>? items) {
    if (items == null) return 0;
    var count = 0;
    for (final item in items) {
      try {
        final decoded = jsonDecode(item.commandJson) as Map<String, dynamic>;
        final payload = decoded['payload'];
        if (payload is Map<String, dynamic> &&
            payload['countId'] == widget.count.id) {
          count += 1;
        }
      } on FormatException {
        // A malformed queued row is not this screen's concern.
      }
    }
    return count;
  }

  Widget _buildBody(CountSessionState session, bool canCount, int queuedCount) {
    if (session.loading && session.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (session.error != null && session.snapshot == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: BaloraColors.error,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                session.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: BaloraColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _notifier.refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final snapshot = session.snapshot;
    if (snapshot == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (queuedCount > 0)
              _OfflineBanner(
                queuedCount: queuedCount,
                onSendNow: () => ref.read(syncEngineProvider).syncNow(),
              ),
            if (!canCount) const _NotDraftBanner(),
            _KpiStrip(summary: snapshot.summary),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _scanController,
                      focusNode: _scanFocus,
                      enabled: canCount,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitTypedBarcode(),
                      decoration: const InputDecoration(
                        hintText: 'امسح أو اكتب الباركود…',
                        prefixIcon: Icon(
                          Icons.qr_code_rounded,
                          color: BaloraColors.primary,
                        ),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: canCount ? _scanWithCamera : null,
                    icon: const Icon(Icons.photo_camera_outlined, size: 20),
                    tooltip: 'مسح بالكاميرا',
                    style: IconButton.styleFrom(
                      backgroundColor: BaloraColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (session.busy)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 1.8),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      session.feedback ?? '',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: session.feedbackIsError
                            ? BaloraColors.error
                            : BaloraColors.success,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _notifier.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: snapshot.lines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final line = snapshot.lines[index];
                    return _LineTile(
                      line: line,
                      enabled: canCount,
                      onTap: () => _editLine(line),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.queuedCount, required this.onSendNow});

  final int queuedCount;
  final VoidCallback onSendNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BaloraColors.warningSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BaloraColors.warningBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: BaloraColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$queuedCount عمليات بانتظار الإرسال — ستُرسل تلقائياً عند عودة الاتصال.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BaloraColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: onSendNow,
            style: TextButton.styleFrom(
              foregroundColor: BaloraColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('إرسال الآن'),
          ),
        ],
      ),
    );
  }
}

class _NotDraftBanner extends StatelessWidget {
  const _NotDraftBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BaloraColors.infoSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: BaloraColors.info),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'البطاقة لم تعد مسودة — العرض للقراءة فقط.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BaloraColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.summary});

  final CountSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _Kpi(label: 'السطور', value: summary.total),
          const SizedBox(width: 8),
          _Kpi(label: 'المجرودة', value: summary.counted),
          const SizedBox(width: 8),
          _Kpi(
            label: 'المطابق',
            value: summary.matched,
            color: BaloraColors.success,
          ),
          const SizedBox(width: 8),
          _Kpi(
            label: 'الفروقات',
            value: summary.variance,
            color: summary.variance > 0
                ? BaloraColors.error
                : BaloraColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: BaloraColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: BaloraColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BaloraColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color ?? BaloraColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.line,
    required this.enabled,
    required this.onTap,
  });

  final CountLine line;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final countedLabel = line.countedQuantity == null
        ? '—'
        : '${line.countedQuantity}';
    return Material(
      color: BaloraColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: BaloraColors.borderSubtle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productName.isEmpty ? 'مادة' : line.productName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: BaloraColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (line.batchNumber?.isNotEmpty == true)
                          line.batchNumber!,
                        if (line.expiryDate != null)
                          'صلاحية ${line.expiryDate}',
                        'المتوقع ${line.expectedQuantity}',
                        'المعدود $countedLabel',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: BaloraColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _DiffChip(difference: line.difference),
              if (enabled) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: BaloraColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  const _DiffChip({required this.difference});

  final int? difference;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (difference) {
      null => ('لم يُجرد', BaloraColors.infoSoft, BaloraColors.textSecondary),
      0 => ('مطابق', BaloraColors.successSoft, BaloraColors.success),
      final value when value < 0 => (
        'عجز ${-value}',
        BaloraColors.errorSoft,
        BaloraColors.error,
      ),
      final value => (
        'زيادة $value',
        BaloraColors.warningSoft,
        BaloraColors.warning,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

