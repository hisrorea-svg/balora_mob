import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/providers.dart';
import '../inventory_providers.dart';

class InventoryReviewScreen extends ConsumerWidget {
  const InventoryReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingItemsAsync = ref.watch(pendingCountCommandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العمليات المعلقة'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'مزامنة الآن',
            onPressed: () {
              ref.read(syncEngineProvider).syncNow();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جارٍ مزامنة العمليات المعلقة مع الكمبيوتر...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'بطاقات الجرد',
            onPressed: () => context.push('/counts'),
          ),
        ],
      ),
      body: SafeArea(
        child: pendingItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: BaloraColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            color: BaloraColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'لا توجد عمليات معلقة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: BaloraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'جميع عمليات العدّ متزامنة مع خادم الصيدلية.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: BaloraColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/counts'),
                          icon: const Icon(Icons.inventory_2_outlined, size: 18),
                          label: const Text('فتح بطاقات الجرد'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final decoded =
                        jsonDecode(item.commandJson) as Map<String, dynamic>;
                    final innerPayload =
                        decoded['payload'] is Map<String, dynamic>
                        ? decoded['payload'] as Map<String, dynamic>
                        : decoded;
                    final isSet = item.commandType == 'countSet';
                    final barcode = (decoded['barcode'] as String?) ?? '';
                    final detail = isSet
                        ? '${innerPayload['packages'] ?? 0} علب + ${innerPayload['looseUnits'] ?? 0} وحدة'
                        : (barcode.isEmpty ? 'مسحة عدّ' : barcode);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
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
                                Icons.inventory_2_outlined,
                                color: BaloraColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSet
                                              ? BaloraColors.warningSoft
                                              : BaloraColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          isSet ? 'تعديل كمية' : 'مسح جرد',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isSet
                                                ? BaloraColors.warning
                                                : BaloraColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail,
                                    textDirection: isSet
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: BaloraColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: BaloraColors.error,
                              ),
                              tooltip: 'حذف',
                              onPressed: () {
                                ref.read(queueDaoProvider).deleteItem(item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('خطأ: $err')),
        ),
      ),
    );
  }
}
