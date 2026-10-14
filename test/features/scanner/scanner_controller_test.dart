import 'package:balora_mob/core/api/dio_client.dart';
import 'package:balora_mob/core/api/models/command.dart';
import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/result/result.dart';
import 'package:balora_mob/core/sync/database/app_database.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/scanner/domain/product.dart';
import 'package:balora_mob/features/scanner/domain/product_repository.dart';
import 'package:balora_mob/features/scanner/domain/scanner_mode.dart';
import 'package:balora_mob/features/scanner/presentation/scanner_controller.dart';
import 'package:balora_mob/features/scanner/presentation/scanner_mode_provider.dart';
import 'package:balora_mob/features/scanner/presentation/scanner_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQueueService extends Mock implements QueueService {}
class MockProductRepository extends Mock implements ProductRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiClient extends Mock implements ApiClient {}
class MockWebSocketService extends Mock implements WebSocketService {}

/// Test-only [ScannerModeNotifier] that returns a fixed mode from
/// [build], because the generated [ScannerModeNotifier.build] always
/// returns [ScannerMode.search] and we need to simulate other modes.
class _FixedModeNotifier extends ScannerModeNotifier {
  _FixedModeNotifier(this._initialMode);
  final ScannerMode _initialMode;
  @override
  ScannerMode build() => _initialMode;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    registerFallbackValue(CommandType.scan);
  });

  late MockQueueService queueService;
  late MockProductRepository productRepository;
  late MockAuthRepository authRepository;
  late ProviderContainer container;

  setUp(() {
    queueService = MockQueueService();
    productRepository = MockProductRepository();
    authRepository = MockAuthRepository();

    when(() => authRepository.getDeviceId()).thenAnswer((_) async => 'dev-1');
  });

  ProviderContainer makeContainer({ScannerMode mode = ScannerMode.search}) {
    final container = ProviderContainer(
      overrides: [
        queueServiceProvider.overrideWithValue(queueService),
        productRepositoryProvider.overrideWithValue(productRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        scannerModeNotifierProvider.overrideWith(() => _FixedModeNotifier(mode)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ScannerController', () {
    test('initial state is idle', () {
      container = makeContainer();
      final state = container.read(scannerControllerProvider);
      expect(state, const ScannerState.idle());
    });

    test('onBarcodeDetected in search mode fetches product successfully', () async {
      container = makeContainer(mode: ScannerMode.search);
      
      const product = Product(
        barcode: '123',
        name: 'Test',
        category: 'Test Category',
        price: 10.0,
        costPrice: 5.0,
        countInBox: 1,
        unitPrice: 10.0,
        quantity: 1,
      );

      when(() => productRepository.getProductByBarcode(
            '123',
            symbology: any(named: 'symbology'),
          )).thenAnswer((_) async => const Success(product));

      final controller = container.read(scannerControllerProvider.notifier);
      await controller.onBarcodeDetected('123');

      verify(() => productRepository.getProductByBarcode(
            '123',
            symbology: 'lookup',
          )).called(1);
      
      final state = container.read(scannerControllerProvider);
      expect(state, const ScannerState.productFound(product));
    });

    test('onBarcodeDetected in search mode handles product not found', () async {
      container = makeContainer(mode: ScannerMode.search);

      when(() => productRepository.getProductByBarcode(
            '123',
            symbology: any(named: 'symbology'),
          )).thenAnswer((_) async => const Failure(NotFoundException('Not found')));

      final controller = container.read(scannerControllerProvider.notifier);
      await controller.onBarcodeDetected('123');

      final state = container.read(scannerControllerProvider);
      expect(state, const ScannerState.productNotFound('123'));
    });

    test('onBarcodeDetected in inventory mode enqueues command instantly', () async {
      container = makeContainer(mode: ScannerMode.inventory);

      when(() => queueService.enqueueCommand(
            type: any(named: 'type'),
            deviceId: any(named: 'deviceId'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => 'cmd-1');

      final controller = container.read(scannerControllerProvider.notifier);
      await controller.onBarcodeDetected('123');

      verify(() => queueService.enqueueCommand(
            type: CommandType.inventoryScan,
            deviceId: 'dev-1',
            payload: any(named: 'payload'),
          )).called(1);
      
      final state = container.read(scannerControllerProvider);
      expect(state, const ScannerState.actionQueued('Inventory count queued'));
    });
    
    test('onBarcodeDetected in receiving mode enqueues command instantly', () async {
      container = makeContainer(mode: ScannerMode.receiving);

      when(() => queueService.enqueueCommand(
            type: any(named: 'type'),
            deviceId: any(named: 'deviceId'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => 'cmd-2');

      final controller = container.read(scannerControllerProvider.notifier);
      await controller.onBarcodeDetected('456');

      verify(() => queueService.enqueueCommand(
            type: CommandType.inventorySubmit,
            deviceId: 'dev-1',
            payload: any(named: 'payload'),
          )).called(1);
      
      final state = container.read(scannerControllerProvider);
      expect(state, const ScannerState.actionQueued('Receiving scan queued'));
    });

    test('reset() preserves same-barcode cooldown to prevent 30fps scan flood, while allowing different barcode immediately', () async {
      container = makeContainer(mode: ScannerMode.sale);

      const productA = Product(
        barcode: '111',
        name: 'Product A',
        category: 'علبة',
        price: 1000.0,
        costPrice: 0.0,
        countInBox: 1,
        unitPrice: 1000.0,
        quantity: 10,
      );
      const productB = Product(
        barcode: '222',
        name: 'Product B',
        category: 'علبة',
        price: 2000.0,
        costPrice: 0.0,
        countInBox: 1,
        unitPrice: 2000.0,
        quantity: 5,
      );

      when(() => productRepository.getProductByBarcode(
            '111',
            symbology: any(named: 'symbology'),
          )).thenAnswer((_) async => const Success(productA));
      when(() => productRepository.getProductByBarcode(
            '222',
            symbology: any(named: 'symbology'),
          )).thenAnswer((_) async => const Success(productB));

      final controller = container.read(scannerControllerProvider.notifier);

      // First scan of '111' succeeds
      await controller.onBarcodeDetected('111');
      controller.reset(); // Simulates UI calling reset() right after scan

      // Immediate second frame of '111' must be blocked by cooldown
      await controller.onBarcodeDetected('111');
      verify(() => productRepository.getProductByBarcode(
            '111',
            symbology: 'pos',
          )).called(1);

      // Immediate scan of a DIFFERENT barcode '222' must succeed with zero delay
      await controller.onBarcodeDetected('222');
      verify(() => productRepository.getProductByBarcode(
            '222',
            symbology: 'pos',
          )).called(1);
    });
  });

  group('Desktop Protocol Alignment (Pairing & Live Scan)', () {
    test('AuthRepository pairs using Desktop URL QR and saves session', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final apiClient = MockApiClient();
      final ws = MockWebSocketService();
      final repo = AuthRepository(apiClient, db, ws);

      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/pair',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Success({
            'ok': true,
            'correlationId': '01950000-0000-7000-8000-000000000001',
            'data': {
              'token': 'mob-token-xyz',
              'sessionId': '01950000-0000-7000-8000-000000000002',
              'label': 'هاتف الرفوف',
              'expiresAt': DateTime.now()
                  .add(const Duration(hours: 8))
                  .toUtc()
                  .toIso8601String(),
            },
          }));

      final res = await repo.pairWithQr(
        'https://192.168.1.15:4784/m/?code=ABCD-EFGH',
        deviceLabel: 'هاتف الرفوف',
      );

      expect(res.isSuccess, isTrue);
      verify(() => apiClient.setBaseUrl('https://192.168.1.15:4784')).called(2);
      verify(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/pair',
            data: {'code': 'ABCD-EFGH', 'label': 'هاتف الرفوف'},
          )).called(1);
      verify(() => ws.setSessionConnected(true)).called(1);

      final saved = await repo.getActiveSession();
      expect(saved, isNotNull);
      expect(saved!.sessionToken, 'mob-token-xyz');
      expect(saved.serverUrl, 'https://192.168.1.15:4784');
      expect(saved.deviceName, 'هاتف الرفوف');
    });

    test('ProductRepository posts to /m/api/scan and converts IQD minor units', () async {
      final apiClient = MockApiClient();
      final repo = ProductRepository(apiClient);

      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/scan',
            data: any(named: 'data'),
          )).thenAnswer((_) async => const Success({
            'ok': true,
            'data': {
              'scanId': '01950000-0000-7000-8000-000000000010',
              'barcode': '6281000001234',
              'productFound': true,
              'productActive': true,
              'productName': 'Panadol Extra',
              'isPackageUnit': true,
              'priceFound': true,
              'priceMinor': 2500000,
              'currency': 'IQD',
              'quantityAvailable': 42,
            },
          }));

      final result = await repo.getProductByBarcode('6281000001234');
      expect(result.isSuccess, isTrue);
      final product = (result as Success<Product>).data;
      expect(product.name, 'Panadol Extra');
      expect(product.price, 2500.0);
      expect(product.quantity, 42);
      expect(product.category, 'علبة');
    });

    test('ProductRepository returns NotFoundException when productFound is false', () async {
      final apiClient = MockApiClient();
      final repo = ProductRepository(apiClient);

      when(() => apiClient.post<Map<String, dynamic>>(
            '/m/api/scan',
            data: any(named: 'data'),
          )).thenAnswer((_) async => const Success({
            'ok': true,
            'data': {
              'scanId': '01950000-0000-7000-8000-000000000011',
              'barcode': '99999999',
              'productFound': false,
              'productActive': false,
              'isPackageUnit': false,
              'priceFound': false,
              'priceMinor': 0,
              'quantityAvailable': 0,
            },
          }));

      final result = await repo.getProductByBarcode('99999999');
      expect(result.isFailure, isTrue);
      expect((result as Failure<Product>).exception, isA<NotFoundException>());
    });
  });
}
