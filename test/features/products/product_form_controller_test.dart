import 'package:balora_mob/core/api/models/command.dart';
import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/products/presentation/product_form_controller.dart';
import 'package:balora_mob/features/products/presentation/product_form_state.dart';
import 'package:balora_mob/features/scanner/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQueueService extends Mock implements QueueService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CommandType.addProduct);
  });

  late MockQueueService queueService;
  late MockAuthRepository authRepository;
  late ProviderContainer container;

  setUp(() {
    queueService = MockQueueService();
    authRepository = MockAuthRepository();

    when(() => authRepository.getDeviceId()).thenAnswer((_) async => 'dev-1');

    container = ProviderContainer(
      overrides: [
        queueServiceProvider.overrideWithValue(queueService),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProductFormController', () {
    test('initial state is idle', () {
      final state = container.read(productFormControllerProvider);
      expect(state, const ProductFormState.idle());
    });

    test('submitProduct (Add) enqueues addProduct command', () async {
      const product = Product(
        barcode: '123',
        name: 'Test',
        category: 'Category',
        price: 50.0,
        costPrice: 25.0,
        countInBox: 10,
        unitPrice: 5.0,
        quantity: 10,
      );

      when(() => queueService.enqueueCommand(
            type: any(named: 'type'),
            deviceId: any(named: 'deviceId'),
            barcode: any(named: 'barcode'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => 'cmd-1');

      final controller = container.read(productFormControllerProvider.notifier);
      await controller.submitProduct(isEdit: false, product: product);

      verify(() => queueService.enqueueCommand(
            type: CommandType.addProduct,
            deviceId: 'dev-1',
            barcode: '123',
            payload: product.toJson(),
          )).called(1);

      final state = container.read(productFormControllerProvider);
      expect(state, const ProductFormState.success());
    });

    test('submitProduct (Edit) enqueues updateProduct command', () async {
      const product = Product(
        barcode: '123',
        name: 'Test',
        category: 'Category',
        price: 50.0,
        costPrice: 25.0,
        countInBox: 10,
        unitPrice: 5.0,
        quantity: 10,
      );

      when(() => queueService.enqueueCommand(
            type: any(named: 'type'),
            deviceId: any(named: 'deviceId'),
            barcode: any(named: 'barcode'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => 'cmd-1');

      final controller = container.read(productFormControllerProvider.notifier);
      await controller.submitProduct(isEdit: true, product: product);

      verify(() => queueService.enqueueCommand(
            type: CommandType.updateProduct,
            deviceId: 'dev-1',
            barcode: '123',
            payload: product.toJson(),
          )).called(1);

      final state = container.read(productFormControllerProvider);
      expect(state, const ProductFormState.success());
    });
  });
}
