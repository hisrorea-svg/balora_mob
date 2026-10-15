import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/result/result.dart';
import '../domain/count_models.dart';
import 'counts_providers.dart';

/// Lists the open stock count drafts of the branch so the phone can join one.
class CountsScreen extends ConsumerWidget {
  const CountsScreen({super.key});

  /// Opens one count and refreshes the list on return so the progress shown
  /// here always reflects what the session just recorded.
  Future<void> _openCount(
    BuildContext context,
    WidgetRef ref,
    ActiveCount count,
  ) async {
    await context.push('/counts/session', extra: count);
    ref.invalidate(activeCountsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(activeCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقات الجرد'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(activeCountsProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: countsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _CountsError(
            message: getErrorMessage(error),
            onRetry: () => ref.invalidate(activeCountsProvider),
          ),
          data: (counts) {
            if (counts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(activeCountsProvider),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [_CountsEmpty()],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(activeCountsProvider),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: counts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _CountCard(
                      count: counts[index],
                      onTap: () => _openCount(context, ref, counts[index]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.count, required this.onTap});

  final ActiveCount count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = count.total == 0 ? 0.0 : count.counted / count.total;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text(
                          count.locationName.isEmpty
                              ? 'موقع غير مسمى'
                              : count.locationName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: BaloraColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (count.note.isNotEmpty)
                          Text(
                            count.note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: BaloraColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: BaloraColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: BaloraColors.primarySoft,
                  valueColor: const AlwaysStoppedAnimation(
                    BaloraColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'جُرد ${count.counted} من أصل ${count.total} سطر',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BaloraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountsEmpty extends StatelessWidget {
  const _CountsEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
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
                  Icons.inventory_2_outlined,
                  color: BaloraColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'لا توجد بطاقات جرد مفتوحة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BaloraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أنشئ بطاقة جرد من شاشة الجرد على الكمبيوتر ثم حدّث هذه القائمة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: BaloraColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountsError extends StatelessWidget {
  const _CountsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
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
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: BaloraColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
