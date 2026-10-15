/// Defines the different intents/modes for the Scanner.
enum ScannerMode {
  /// Simple lookup. Queries the database directly. Does not queue any commands.
  search(
    'Search',
    'Find and view product details',
    'بحث واستعلام',
    'فحص تفاصيل المنتج وسعره',
  ),

  /// Add or edit a product. Queues `AddProductCommand` or `UpdateProductCommand`.
  product(
    'Product',
    'Add or edit product',
    'المنتجات',
    'إضافة أو تعديل المنتجات',
  ),

  /// POS Sale mode. Sends `posScan` command directly to the active invoice.
  sale(
    'Sale',
    'POS Scanner mode',
    'نقطة البيع (POS)',
    'مسح الباركود للبيع المباشر',
  );

  final String title;
  final String description;
  final String arabicTitle;
  final String arabicDescription;

  const ScannerMode(
    this.title,
    this.description,
    this.arabicTitle,
    this.arabicDescription,
  );
}
