import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_product.freezed.dart';
part 'draft_product.g.dart';

/// Represents a pharmaceutical product draft entered via mobile device
/// and held in staging before desktop review and atomic commit.
@freezed
abstract class DraftProduct with _$DraftProduct {
  const factory DraftProduct({
    /// Barcode of the box/package
    required String barcode,

    /// Barcode of an individual strip or unit (optional)
    String? stripBarcode,

    /// Commercial/Arabic name
    required String nameAr,

    /// English name (for label printers)
    String? nameEn,

    /// Active ingredient / scientific formula
    String? scientificName,

    /// Drug category (e.g. Antibiotic, Analgesic)
    @Default('أدوية') String category,

    /// Pharmaceutical form (e.g. Capsule, Syrup, Tablet, Ampoule)
    String? dosageForm,

    /// Manufacturing company
    String? manufacturer,

    /// Box cost price (IQD)
    @Default(0.0) double costPriceBox,

    /// Box selling price (IQD)
    @Default(0.0) double sellPriceBox,

    /// Number of strips/units per box
    @Default(1) int stripsPerBox,

    /// Unit cost price (IQD)
    @Default(0.0) double costPriceUnit,

    /// Unit selling price (IQD)
    @Default(0.0) double sellPriceUnit,

    /// Opening stock quantity
    @Default(0) int quantity,

    /// Bonus quantity received free from supplier
    @Default(0) int bonus,

    /// Purchase unit: 'box' or 'unit'
    @Default('box') String purchaseUnit,

    /// Unit of opening stock ('box' or 'unit')
    @Default('box') String quantityUnit,

    /// Batch or lot number
    String? batchNumber,

    /// Expiration date (formatted as YYYY-MM or YYYY-MM-DD)
    String? expiryDate,

    /// Shelf/storage location (e.g. A-12, Ref-3)
    String? shelfLocation,

    /// Any additional notes
    String? notes,
  }) = _DraftProduct;

  factory DraftProduct.fromJson(Map<String, dynamic> json) =>
      _$DraftProductFromJson(json);
}
