import 'package:balora_mob/app/router.dart';
import 'package:balora_mob/core/api/dio_client.dart';
import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/result/result.dart';
import 'package:balora_mob/core/security/secure_session_store.dart';
import 'package:balora_mob/core/sync/database/app_database.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/auth/domain/link_preferences.dart';
import 'package:balora_mob/features/auth/presentation/auth_controller.dart';
import 'package:balora_mob/features/auth/presentation/link_screen.dart';
import 'package:balora_mob/features/home/presentation/home_screen.dart';
import 'package:balora_mob/features/inventory/presentation/inventory_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockWebSocketService extends Mock implements WebSocketService {}

class MockAuthRepository extends Mock implements AuthRepository {}

/// In-memory [SessionTokenStore] so pairing tests do not need the
/// platform secure-storage channel.
class FakeTokenStore implements SessionTokenStore {
  String? token;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async {
    token = value;
  }

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}

Map<String, dynamic> pairResponse({required DateTime expiresAt}) => {
  'ok': true,
  'data': {
    'token': 'mob-token-xyz',
    'sessionId': '01950000-0000-7000-8000-000000000002',
    'label': 'هاتف الرفوف',
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  },
};

Future<void> seedSession(
  AppDatabase db, {
  DateTime? expiresAt,
  String serverUrl = 'https://192.168.1.15:4784',
}) async {
  await db
      .into(db.sessions)
      .insert(
        SessionsCompanion.insert(
          sessionToken: '',
          serverUrl: serverUrl,
          deviceId: 'dev-1',
          deviceName: 'هاتف الرفوف',
          expiresAt:
              expiresAt ?? DateTime.now().add(const Duration(hours: 8)),
          createdAt: DateTime.now(),
        ),
      );
}

Future<void> seedQueueItem(AppDatabase db) async {
  await db
      .into(db.queueItems)
      .insert(
        QueueItemsCompanion.insert(
          id: 'cmd-1',
          commandJson: '{"deviceId":"dev-1","type":"scan"}',
          commandType: 'scan',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue('');
  });

  group('pairWithCode', () {
    late AppDatabase db;
    late MockApiClient apiClient;
    late MockWebSocketService ws;
    late FakeTokenStore tokenStore;
    late AuthRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      apiClient = MockApiClient();
      ws = MockWebSocketService();
      tokenStore = FakeTokenStore();
      repo = AuthRepository(apiClient, db, ws, tokenStore: tokenStore);
    });

    test('pairs with a 6-digit code through the same path as QR pairing',
        () async {
      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/pair',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Success(
          pairResponse(
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          ),
        ),
      );

      // Bare host:port is normalized to an https base URL.
      final res = await repo.pairWithCode(
        serverUrl: '192.168.1.15:4784',
        code: '123456',
        deviceLabel: 'هاتف الرفوف',
      );

      expect(res.isSuccess, isTrue);
      verify(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/pair',
          data: {'code': '123456', 'label': 'هاتف الرفوف'},
        ),
      ).called(1);
      verify(
        () => apiClient.setBaseUrl('https://192.168.1.15:4784'),
      ).called(2);
      verify(() => ws.setSessionConnected(true)).called(1);

      final saved = await repo.getActiveSession();
      expect(saved, isNotNull);
      expect(saved!.sessionToken, isEmpty);
      expect(tokenStore.token, 'mob-token-xyz');
      expect(saved.serverUrl, 'https://192.168.1.15:4784');
      expect(saved.deviceName, 'هاتف الرفوف');
    });

    test('rejects codes that are not exactly 6 digits without calling the server',
        () async {
      for (final badCode in ['12345', '1234567', 'abcdef', '12 456', '']) {
        final res = await repo.pairWithCode(
          serverUrl: 'https://192.168.1.15:4784',
          code: badCode,
        );
        expect(res.isFailure, isTrue, reason: 'code "$badCode"');
      }
      verifyNever(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/pair',
          data: any(named: 'data'),
        ),
      );
    });

    test('rejects an unusable server address without calling the server',
        () async {
      for (final badServer in ['', 'http://', '::::']) {
        final res = await repo.pairWithCode(
          serverUrl: badServer,
          code: '123456',
        );
        expect(res.isFailure, isTrue, reason: 'server "$badServer"');
      }
      verifyNever(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/pair',
          data: any(named: 'data'),
        ),
      );
    });

    test('a server failure saves no session', () async {
      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/pair',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Failure(UnknownException('bad code')),
      );

      final res = await repo.pairWithCode(
        serverUrl: 'https://192.168.1.15:4784',
        code: '123456',
      );

      expect(res.isFailure, isTrue);
      expect(await db.select(db.sessions).getSingleOrNull(), isNull);
      expect(tokenStore.token, isNull);
    });
  });

  group('sliding renewal (connectFromActiveSession)', () {
    late AppDatabase db;
    late MockApiClient apiClient;
    late MockWebSocketService ws;
    late FakeTokenStore tokenStore;
    late AuthRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      apiClient = MockApiClient();
      ws = MockWebSocketService();
      tokenStore = FakeTokenStore()..token = 'mob-token-xyz';
      repo = AuthRepository(apiClient, db, ws, tokenStore: tokenStore);
    });

    test('persists a refreshed expiresAt from a successful session check',
        () async {
      await seedSession(db);
      final refreshed = DateTime.now().add(const Duration(days: 30));

      when(
        () => apiClient.get<Map<String, dynamic>>('/m/api/session'),
      ).thenAnswer(
        (_) async => Success({
          'ok': true,
          'data': {'expiresAt': refreshed.toUtc().toIso8601String()},
        }),
      );

      expect(await repo.connectFromActiveSession(), isTrue);

      final saved = await db.select(db.sessions).getSingleOrNull();
      expect(saved, isNotNull);
      // The stored expiry moved to (approximately) the refreshed value.
      expect(
        saved!.expiresAt.isAfter(DateTime.now().add(const Duration(days: 29))),
        isTrue,
      );
    });

    test('keeps the stored expiry when the check carries none', () async {
      final original = DateTime.now().add(const Duration(hours: 8));
      await seedSession(db, expiresAt: original);

      when(
        () => apiClient.get<Map<String, dynamic>>('/m/api/session'),
      ).thenAnswer((_) async => const Success({'ok': true}));

      expect(await repo.connectFromActiveSession(), isTrue);

      final saved = await db.select(db.sessions).getSingleOrNull();
      expect(saved, isNotNull);
      expect(
        saved!.expiresAt.difference(original).abs() <
            const Duration(seconds: 1),
        isTrue,
      );
    });
  });

  group('expiry keeps the offline queue', () {
    test('an expired session is purged but queued items survive', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final apiClient = MockApiClient();
      final ws = MockWebSocketService();
      final repo = AuthRepository(
        apiClient,
        db,
        ws,
        tokenStore: FakeTokenStore()..token = 'mob-token-xyz',
      );

      await seedSession(
        db,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await seedQueueItem(db);

      expect(await repo.getActiveSession(), isNull);
      expect(await db.select(db.sessions).getSingleOrNull(), isNull);

      final queue = await db.select(db.queueItems).get();
      expect(queue, hasLength(1));
      expect(queue.first.id, 'cmd-1');
    });
  });

  group('AuthController pairWithCode', () {
    late MockAuthRepository authRepository;
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authRepository = MockAuthRepository();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          linkPreferencesProvider.overrideWith(
            (ref) async => LinkPreferences(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test('an invalid code format never reaches the repository', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.pairWithCode(
        serverUrl: 'https://192.168.1.15:4784',
        code: '12345',
      );

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      verifyNever(
        () => authRepository.pairWithCode(
          serverUrl: any(named: 'serverUrl'),
          code: any(named: 'code'),
          deviceLabel: any(named: 'deviceLabel'),
        ),
      );
    });

    test('locks code pairing after 5 consecutive failures', () async {
      when(
        () => authRepository.pairWithCode(
          serverUrl: any(named: 'serverUrl'),
          code: any(named: 'code'),
          deviceLabel: any(named: 'deviceLabel'),
        ),
      ).thenAnswer(
        (_) async => const Failure(UnknownException('bad code')),
      );

      final controller = container.read(authControllerProvider.notifier);

      for (var i = 0; i < 5; i++) {
        await controller.pairWithCode(
          serverUrl: 'https://192.168.1.15:4784',
          code: '123456',
        );
      }
      // Sixth attempt: locked, the repository is not called again.
      await controller.pairWithCode(
        serverUrl: 'https://192.168.1.15:4784',
        code: '123456',
      );

      verify(
        () => authRepository.pairWithCode(
          serverUrl: any(named: 'serverUrl'),
          code: any(named: 'code'),
          deviceLabel: any(named: 'deviceLabel'),
        ),
      ).called(5);
      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        getErrorMessage(state.error),
        contains('محاولات كثيرة'),
      );
    });

    test('a successful pairing remembers the server for next time',
        () async {
      final now = DateTime.now();
      when(
        () => authRepository.pairWithCode(
          serverUrl: any(named: 'serverUrl'),
          code: any(named: 'code'),
          deviceLabel: any(named: 'deviceLabel'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(() => authRepository.getActiveSession()).thenAnswer(
        (_) async => SessionEntry(
          id: 1,
          sessionToken: '',
          serverUrl: 'https://192.168.1.15:4784',
          deviceId: 'dev-1',
          deviceName: 'هاتف الرفوف',
          expiresAt: now.add(const Duration(days: 30)),
          permissions: '',
          createdAt: now,
          isActive: true,
        ),
      );

      final controller = container.read(authControllerProvider.notifier);
      await controller.pairWithCode(
        serverUrl: '192.168.1.15:4784',
        code: '123456',
      );

      expect(container.read(authControllerProvider).hasError, isFalse);
      expect(
        prefs.getString('balora_last_server_url'),
        'https://192.168.1.15:4784',
      );
    });
  });

  group('guest-mode routing', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
    });

    Future<void> pumpRouter(
      WidgetTester tester, {
      required String initialLocation,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialLocationProvider.overrideWithValue(initialLocation),
            appDatabaseProvider.overrideWithValue(db),
            // Home watches the pending-count stream (a Drift stream
            // query). Overriding it with a fixed empty stream keeps
            // these routing tests focused, and avoids Drift scheduling
            // a close timer during disposal that trips flutter_test's
            // "no pending timers" invariant.
            pendingCountCommandsProvider.overrideWith(
              (ref) => Stream.value(const <QueueItemEntry>[]),
            ),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      // Bounded pumps instead of pumpAndSettle: the pairing screen
      // hosts the live camera widget, whose animation never settles
      // in a test, so pumpAndSettle would hang forever.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
    }

    testWidgets('home opens without a session and shows the link banner',
        (tester) async {
      await pumpRouter(tester, initialLocation: '/home');

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LinkScreen), findsNothing);
      expect(find.text('غير مربوط بالكمبيوتر'), findsOneWidget);
      expect(find.text('ربط'), findsOneWidget);
    });

    testWidgets('the pairing route is still reachable as a deep link',
        (tester) async {
      await pumpRouter(tester, initialLocation: '/pairing');

      expect(find.byType(LinkScreen), findsOneWidget);
      expect(find.text('Scan QR Code to Sign In'), findsOneWidget);
      expect(find.text('مسح QR'), findsOneWidget);
      expect(find.text('كود 6 أرقام'), findsOneWidget);
    });
  });
}
