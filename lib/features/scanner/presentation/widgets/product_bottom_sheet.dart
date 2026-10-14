import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/product.dart';

/// A bottom sheet that displays product details or prompts to add a missing product.
class ProductBottomSheet extends StatelessWidget {
  final String barcode;
  final Product? product;
  final VoidCallback onDismiss;
  final VoidCallback? onAddProduct;
  final VoidCallback? onEditProduct;

  const ProductBottomSheet({
    super.key,
    required this.barcode,
    this.product,
    required this.onDismiss,
    this.onAddProduct,
    this.onEditProduct,
  });

  /// Displays the sheet. Returns a future that completes when the sheet is closed.
  static Future<void> show(
    BuildContext context, {
    required String barcode,
    Product? product,
    required VoidCallback onDismiss,
    VoidCallback? onAddProduct,
    VoidCallback? onEditProduct,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductBottomSheet(
        barcode: barcode,
        product: product,
        onDismiss: onDismiss,
        onAddProduct: onAddProduct,
        onEditProduct: onEditProduct,
      ),
    ).whenComplete(onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: const BoxDecoration(
            color: BaloraColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: BaloraColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                if (product != null)
                  _buildProductDetails(context, product!)
                else
                  _buildNotFound(context),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('إغلاق'),
                      ),
                    ),
                    if (product != null && onEditProduct != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEditProduct!();
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('تعديل'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(Product p) {
    if (p.description == 'بدون تسعير') {
      return 'غير معرف';
    }
    final currency = (p.description != null && p.description!.isNotEmpty)
        ? p.description!
        : 'IQD';
    if (currency.toUpperCase() == 'IQD') {
      final intPart = p.price.round();
      final formatted = intPart.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
      return '$formatted د.ع';
    }
    return '${p.price.toStringAsFixed(2)} $currency';
  }

  Widget _buildProductDetails(BuildContext context, Product p) {
    final isInactive = p.category == 'موقوف';
    final badgeBg = isInactive
        ? BaloraColors.warningSoft
        : BaloraColors.primarySoft;
    final badgeFg = isInactive ? BaloraColors.warning : BaloraColors.primary;
    final hasStock = p.quantity > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: BaloraColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (p.scientificName != null && p.scientificName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        p.scientificName!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: BaloraColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                p.category,
                style: TextStyle(
                  color: badgeFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (isInactive)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BaloraColors.warningSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'هذا المنتج موقوف من البيع.',
              style: TextStyle(
                color: BaloraColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        const SizedBox(height: 16),

        // بطاقتا السعر والرصيد المتوفر جنباً إلى جنب لقراءة فورية
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BaloraColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BaloraColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'السعر',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaloraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(p),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BaloraColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasStock
                      ? BaloraColors.successSoft.withValues(alpha: 0.5)
                      : BaloraColors.errorSoft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        (hasStock ? BaloraColors.success : BaloraColors.error)
                            .withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الرصيد المتوفر',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaloraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: hasStock
                            ? BaloraColors.success
                            : BaloraColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        _buildInfoRow(context, 'الباركود', p.barcode, isLtr: true),
        if (p.costPrice > 0)
          _buildInfoRow(context, 'سعر الشراء', p.costPrice.toStringAsFixed(2)),
        if (p.countInBox > 1)
          _buildInfoRow(context, 'العدد في العلبة', p.countInBox.toString()),
        if (p.manufacturer != null && p.manufacturer!.isNotEmpty)
          _buildInfoRow(context, 'الشركة المصنعة', p.manufacturer!),
        if (p.expiryDate != null)
          _buildInfoRow(
            context,
            'تاريخ الانتهاء',
            '${p.expiryDate!.year}-${p.expiryDate!.month.toString().padLeft(2, '0')}-${p.expiryDate!.day.toString().padLeft(2, '0')}',
            isLtr: true,
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isLtr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: BaloraColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textDirection: isLtr ? TextDirection.ltr : null,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? BaloraColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        Text(
          'المنتج غير موجود',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'الباركود: $barcode',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: BaloraColors.textSecondary),
        ),
        const SizedBox(height: 24),
        if (onAddProduct != null)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onAddProduct!();
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة المنتج للقاعدة'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
      ],
    );
  }
}
