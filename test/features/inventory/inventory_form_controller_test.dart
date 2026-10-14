import 'package:balora_mob/core/api/models/command.dart';
import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/inventory/presentation/inventory_form_controller.dart';
import 'package:balora_mob/features/inventory/presentation/inventory_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQueueService extends Mock implements QueueService {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CommandType.inventoryScan);
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

  group('InventoryFormController', () {
    test('initial state is idle', () {
      final state = container.read(inventoryFormControllerProvider);
      expect(state, const InventoryFormState.idle());
    });

    test('submitInventory enqueues inventoryScan command', () async {
      when(
        () => queueService.enqueueCommand(
          type: any(named: 'type'),
          deviceId: any(named: 'deviceId'),
          barcode: any(named: 'barcode'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async => 'cmd-1');

      final controller = container.read(
        inventoryFormControllerProvider.notifier,
      );
      await controller.submitInventory(
        type: CommandType.inventoryScan,
        barcode: '123',
        quantity: 5,
      );

      verify(
        () => queueService.enqueueCommand(
          type: CommandType.inventoryScan,
          deviceId: 'dev-1',
          barcode: '123',
          payload: {'barcode': '123', 'quantity': 5, 'action': 'count'},
        ),
      ).called(1);

      final state = container.read(inventoryFormControllerProvider);
      expect(state, const InventoryFormState.success());
    });

    test('submitInventory enqueues inventorySubmit command', () async {
      when(
        () => queueService.enqueueCommand(
          type: any(named: 'type'),
          deviceId: any(named: 'deviceId'),
          barcode: any(named: 'barcode'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async => 'cmd-1');

      final controller = container.read(
        inventoryFormControllerProvider.notifier,
      );
      await controller.submitInventory(
        type: CommandType.inventorySubmit,
        barcode: '456',
        quantity: 10,
      );

      verify(
        () => queueService.enqueueCommand(
          type: CommandType.inventorySubmit,
          deviceId: 'dev-1',
          barcode: '456',
          payload: {'barcode': '456', 'quantity': 10, 'action': 'receive'},
        ),
      ).called(1);

      final state = container.read(inventoryFormControllerProvider);
      expect(state, const InventoryFormState.success());
    });
  });
}
