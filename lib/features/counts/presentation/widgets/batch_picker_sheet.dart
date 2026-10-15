import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/count_models.dart';
import '../count_session_state.dart';

/// Bottom sheet shown when a scanned product has several active batches; the
/// operator picks the batch printed on the box.
class BatchPickerSheet extends StatelessWidget {
  const BatchPickerSheet({super.key, required this.request});

  final BatchSelectionRequest request;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              request.productName,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: BaloraColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            const Text(
              'هذه المادة بعدة دفعات — اختر الدفعة المطابقة للعلبة.',
              style: TextStyle(
                fontSize: 12.5,
                color: BaloraColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: request.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = request.options[index];
                  return _BatchOptionTile(option: option);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchOptionTile extends StatelessWidget {
  const _BatchOptionTile({required this.option});

  final CountBatchOption option;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaloraColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(option),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: BaloraColors.borderSubtle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                color: BaloraColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.batchNumber?.isNotEmpty == true
                          ? option.batchNumber!
                          : 'دفعة رئيسية',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: BaloraColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (option.expiryDate != null)
                          'صلاحية ${option.expiryDate}',
                        'متاح ${option.availableQuantity}',
                        'متوقع ${option.expectedQuantity}',
                        if (option.countedQuantity != null)
                          'معدود ${option.countedQuantity}',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: BaloraColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: BaloraColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
