import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A domain model for a Product, aligned with Balora Desktop schema.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String barcode,
    required String name,
    String? scientificName,
    required String category,
    String? manufacturer,

    /// Pricing
    required double price, // سعر البيع (علبة)
    required double costPrice, // سعر الشراء (علبة)
    required int countInBox, // العدد في العلبة
    required double unitPrice, // سعر البيع (وحدة)
    /// Stock
    required int quantity, // الكمية الافتتاحية
    DateTime? expiryDate, // تاريخ الانتهاء
    /// Optional
    String? storageLocation, // موقع التخزين
    String? description,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
