class DrugSuggestion {
  final String name;
  final String? scientificName;
  final String? manufacturer;
  final String? category;
  final String? barcode;
  final String? dosageForm;
  final int? stripsPerBox;
  final double? suggestedPrice;
  final double? suggestedCost;

  const DrugSuggestion({
    required this.name,
    this.scientificName,
    this.manufacturer,
    this.category,
    this.barcode,
    this.dosageForm,
    this.stripsPerBox,
    this.suggestedPrice,
    this.suggestedCost,
  });

  factory DrugSuggestion.fromJson(Map<String, dynamic> json) {
    final priceVal = json['price'];
    final costVal = json['cost'];
    final barcodeVal = json['barcode'] as String?;
    final dosageVal = json['dosageForm'] as String? ?? json['category'] as String?;
    final stripsVal = json['stripsPerBox'] ?? json['countInBox'];

    return DrugSuggestion(
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String?,
      manufacturer: json['manufacturer'] as String?,
      category: json['category'] as String?,
      barcode: (barcodeVal != null && barcodeVal.trim().isNotEmpty)
          ? barcodeVal.trim()
          : null,
      dosageForm: dosageVal,
      stripsPerBox: (stripsVal is num) ? stripsVal.toInt() : null,
      suggestedPrice: (priceVal is num) ? priceVal.toDouble() : null,
      suggestedCost: (costVal is num) ? costVal.toDouble() : null,
    );
  }
}
