import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = state.session;
    final connected = state.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Connection Status Card ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: connected
                                  ? BaloraColors.successSoft
                                  : BaloraColors.errorSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              connected
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_off_outlined,
                              color: connected
                                  ? BaloraColors.success
                                  : BaloraColors.error,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'حالة الاتصال بخادم الصيدلية',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: BaloraColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  connected
                                      ? 'متصل وجاهز للمسح الفوري'
                                      : 'غير متصل بالخادم المحلي',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: connected
                                        ? BaloraColors.success
                                        : BaloraColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Session Info Card ---
                  if (session != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'معلومات الجلسة',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: BaloraColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'اسم الهاتف',
                              session.deviceName,
                            ),
                            const Divider(height: 18),
                            _buildInfoRow(
                              context,
                              'عنوان الخادم',
                              session.serverUrl,
                              isLtr: true,
                            ),
                            const Divider(height: 18),
                            _buildInfoRow(
                              context,
                              'معرف الجلسة',
                              session.deviceId,
                              isLtr: true,
                            ),
                            const Divider(height: 18),
                            _buildInfoRow(
                              context,
                              'تاريخ الاقتران',
                              _formatDate(session.createdAt),
                              isLtr: true,
                            ),
                            const Divider(height: 18),
                            _buildInfoRow(
                              context,
                              'صلاحية الجلسة حتى',
                              _formatDate(session.expiresAt),
                              isLtr: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- Sync Queue Card ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: BaloraColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.sync_rounded,
                              color: BaloraColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'عمليات المزامنة المعلقة',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: BaloraColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'العمليات المحفوظة محلياً بانتظار الإرسال',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: BaloraColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: state.pendingQueueCount > 0
                                  ? BaloraColors.warningSoft
                                  : BaloraColors.successSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${state.pendingQueueCount}',
                              style: TextStyle(
                                color: state.pendingQueueCount > 0
                                    ? BaloraColors.warning
                                    : BaloraColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Link / Unlink ---
                  if (session == null)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/pairing'),
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'ربط مع الدسكتوب',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BaloraColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _showUnpairConfirmation(context, ref),
                      icon: const Icon(
                        Icons.link_off_rounded,
                        color: BaloraColors.error,
                        size: 20,
                      ),
                      label: const Text(
                        'إلغاء اقتران هذا الهاتف',
                        style: TextStyle(
                          color: BaloraColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: BaloraColors.error.withValues(alpha: 0.4),
                        ),
                        backgroundColor: BaloraColors.errorSoft.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isLtr = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: BaloraColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textDirection: isLtr ? TextDirection.ltr : null,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: BaloraColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showUnpairConfirmation(BuildContext context, WidgetRef ref) {
    // Unpairing purges the offline queue (its items carry the old
    // deviceId), so warn explicitly when unsynced work would be lost.
    final pendingCount = ref.read(settingsControllerProvider).pendingQueueCount;
    final content = pendingCount > 0
        ? 'سيؤدي هذا إلى إنهاء الجلسة الحالية وفصل الاتصال بنظام Balora للكمبيوتر، '
              'وسيتم حذف $pendingCount عملية غير متزامنة نهائياً ولا يمكن استرجاعها. '
              'زامِن عملياتك أولاً إذا كنت تريد الاحتفاظ بها.'
        : 'سيؤدي هذا إلى إنهاء الجلسة الحالية وفصل الاتصال بنظام Balora للكمبيوتر.';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء اقتران الجهاز؟'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              // unpair() flips [authStateProvider] to `false`; the
              // screen rebuilds with no session and offers linking
              // again. In guest mode there is no forced redirect.
              ref.read(settingsControllerProvider.notifier).unpair();
            },
            child: const Text(
              'إلغاء الاقتران',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
