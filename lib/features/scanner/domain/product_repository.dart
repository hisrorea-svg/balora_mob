import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/providers.dart';
import '../../../../core/result/result.dart';
import 'product.dart';

part 'product_repository.g.dart';

/// Provides the [ProductRepository].
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(apiClientProvider));
}

/// Handles live barcode scanning and product lookup against Balora Desktop.
class ProductRepository {
  final ApiClient _apiClient;
  static const _uuid = Uuid();

  ProductRepository(this._apiClient);

  /// Records a scan on Balora Desktop (`POST /m/api/scan`) and returns the
  /// resolved [Product] (name, IQD price, and available balance).
  ///
  /// Returns [Success] with [Product] when `productFound == true`, or
  /// [Failure] with [NotFoundException] when `productFound == false`.
  Future<Result<Product>> getProductByBarcode(
    String barcode, {
    String symbology = '',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/m/api/scan',
      data: {'scanId': _uuid.v4(), 'barcode': barcode, 'symbology': symbology},
    );

    switch (response) {
      case Success(:final data):
        try {
          final scanData = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;

          if (scanData.containsKey('productFound')) {
            final productFound = scanData['productFound'] as bool? ?? false;
            if (!productFound) {
              return Failure(
                NotFoundException(
                  'المنتج غير موجود: $barcode',
                  StackTrace.current,
                ),
              );
            }

            final productActive = scanData['productActive'] as bool? ?? true;
            final isPackageUnit = scanData['isPackageUnit'] as bool? ?? true;
            final priceFound = scanData['priceFound'] as bool? ?? false;
            final priceMinor = (scanData['priceMinor'] as num?)?.toInt() ?? 0;
            final rawCurrency = (scanData['currency'] as String?)?.trim();
            final currency = (rawCurrency != null && rawCurrency.isNotEmpty)
                ? rawCurrency
                : 'IQD';
            final divisor = currency.toUpperCase() == 'IQD' ? 1000.0 : 100.0;
            final majorPrice = priceFound ? (priceMinor / divisor) : 0.0;
            final quantityAvailable =
                (scanData['quantityAvailable'] as num?)?.toInt() ?? 0;
            final rawName = (scanData['productName'] as String?)?.trim();
            final productName = (rawName != null && rawName.isNotEmpty)
                ? rawName
                : 'منتج بدون اسم';

            return Success(
              Product(
                barcode: (scanData['barcode'] as String?) ?? barcode,
                name: productName,
                category: !productActive
                    ? 'موقوف'
                    : (isPackageUnit ? 'علبة' : 'وحدة'),
                price: majorPrice,
                costPrice: 0.0,
                countInBox: 1,
                unitPrice: majorPrice,
                quantity: quantityAvailable,
                description: priceFound ? currency : 'بدون تسعير',
              ),
            );
          }

          return Success(Product.fromJson(scanData));
        } catch (e, st) {
          return Failure(UnknownException('Invalid product data: $e', st));
        }
      case Failure(:final exception):
        return Failure(exception);
    }
  }
}
