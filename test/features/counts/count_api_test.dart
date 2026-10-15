import 'package:balora_mob/core/api/dio_client.dart';
import 'package:balora_mob/core/result/result.dart';
import 'package:balora_mob/features/counts/data/count_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late CountApi countApi;

  setUp(() {
    apiClient = MockApiClient();
    countApi = CountApi(apiClient);
  });

  group('CountApi reads', () {
    test('listActiveCounts unwraps the envelope into drafts', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>('/m/api/counts/active'),
      ).thenAnswer(
        (_) async => const Success({
          'ok': true,
          'data': {
            'counts': [
              {
                'id': 'c1',
                'locationId': 'loc-1',
                'locationName': 'المخزن الرئيسي',
                'note': 'جرد دوري',
                'createdAt': '2026-10-15T08:00:00Z',
                'total': 120,
                'counted': 34,
              },
            ],
          },
        }),
      );

      final counts = await countApi.listActiveCounts();

      expect(counts, hasLength(1));
      expect(counts.single.id, 'c1');
      expect(counts.single.locationName, 'المخزن الرئيسي');
      expect(counts.single.total, 120);
      expect(counts.single.counted, 34);
    });

    test('getCountSummary parses header, KPI and lines', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>(
          '/m/api/counts/c1/summary',
          queryParameters: {'limit': 200, 'offset': 0},
        ),
      ).thenAnswer(
        (_) async => const Success({
          'ok': true,
          'data': {
            'count': {
              'id': 'c1',
              'locationId': 'loc-1',
              'locationName': 'المخزن الرئيسي',
              'note': '',
              'status': 'draft',
            },
            'summary': {'total': 2, 'counted': 1, 'matched': 0, 'variance': 1},
            'lines': [
              {
                'lineId': 'l1',
                'productId': 'p1',
                'productName': 'أموكسيسيلين',
                'batchId': 'b1',
                'batchNumber': 'AMX-1',
                'expiryDate': '2027-01-31',
                'unitsPerPackage': 20,
                'expectedQuantity': 50,
                'countedQuantity': 45,
                'difference': -5,
              },
              {
                'lineId': 'l2',
                'productId': 'p2',
                'productName': 'إيبوبروفين',
                'unitsPerPackage': 1,
                'expectedQuantity': 10,
                'countedQuantity': null,
                'difference': null,
              },
            ],
            'total': 2,
            'limit': 200,
            'offset': 0,
          },
        }),
      );

      final snapshot = await countApi.getCountSummary('c1');

      expect(snapshot.id, 'c1');
      expect(snapshot.isDraft, isTrue);
      expect(snapshot.summary.total, 2);
      expect(snapshot.lines, hasLength(2));
      expect(snapshot.lines.first.countedQuantity, 45);
      expect(snapshot.lines.first.difference, -5);
      expect(snapshot.lines.last.countedQuantity, isNull);
      expect(snapshot.lines.last.isCounted, isFalse);
    });

    test('maps a Problem Details response to CountApiException', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>(
          '/m/api/counts/c1/summary',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          ServerException(
            'problem',
            statusCode: 403,
            serverMessage:
                '{"code":"count_permission_denied","detail":"ليست لديك صلاحية عرض بطاقات الجرد."}',
          ),
        ),
      );

      expect(
        () => countApi.getCountSummary('c1'),
        throwsA(
          isA<CountApiException>()
              .having((e) => e.code, 'code', 'count_permission_denied')
              .having((e) => e.status, 'status', 403)
              .having(
                (e) => e.message,
                'message',
                'ليست لديك صلاحية عرض بطاقات الجرد.',
              ),
        ),
      );
    });
  });

  group('CountApi commands', () {
    test('scan posts the frozen count_scan contract', () async {
      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/commands',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Success({
          'ok': true,
          'commandId': 'cmd-1',
          'status': 'success',
          'message': 'تم تسجيل الكمية في بطاقة الجرد.',
          'data': {
            'countId': 'c1',
            'lineId': 'l1',
            'productId': 'p1',
            'productName': 'أموكسيسيلين',
            'batchId': 'b1',
            'batchNumber': 'AMX-1',
            'expiryDate': '2027-01-31',
            'unitsPerPackage': 20,
            'expectedQuantity': 50,
            'countedQuantity': 20,
            'difference': -30,
          },
        }),
      );

      final result = await countApi.scan(
        commandId: 'cmd-1',
        countId: 'c1',
        barcode: 'AMX-PKG',
      );

      expect(result.isSuccess, isTrue);
      expect(result.countedQuantity, 20);
      expect(result.difference, -30);

      final body =
          verify(
                () => apiClient.post<Map<String, dynamic>>(
                  '/m/api/commands',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body['type'], 'count_scan');
      expect(body['barcode'], 'AMX-PKG');
      expect(body['commandId'], 'cmd-1');
      final payload = body['payload'] as Map<String, dynamic>;
      expect(payload['countId'], 'c1');
      expect(payload.containsKey('batchId'), isFalse);
    });

    test('scan carries the chosen batch when provided', () async {
      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/commands',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Success({
          'ok': true,
          'commandId': 'cmd-2',
          'status': 'failure',
          'message': 'هذه المادة بعدة دفعات.',
          'data': {
            'code': 'count_batch_selection_required',
            'productId': 'p1',
            'productName': 'أموكسيسيلين',
            'batches': [
              {
                'batchId': 'b1',
                'batchNumber': 'AMX-1',
                'expiryDate': '2027-01-31',
                'availableQuantity': 40,
                'countedQuantity': null,
                'expectedQuantity': 50,
              },
              {
                'batchId': 'b2',
                'batchNumber': 'AMX-2',
                'expiryDate': '2027-06-30',
                'availableQuantity': 10,
                'countedQuantity': 5,
                'expectedQuantity': 10,
              },
            ],
          },
        }),
      );

      final result = await countApi.scan(
        commandId: 'cmd-2',
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: 'b1',
      );

      expect(result.isSuccess, isFalse);
      expect(result.code, 'count_batch_selection_required');
      expect(result.batchOptions, hasLength(2));
      expect(result.batchOptions.first.batchNumber, 'AMX-1');
      expect(result.batchOptions.last.countedQuantity, 5);

      final body =
          verify(
                () => apiClient.post<Map<String, dynamic>>(
                  '/m/api/commands',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect((body['payload'] as Map<String, dynamic>)['batchId'], 'b1');
    });

    test('setQuantity posts packages and loose units', () async {
      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/m/api/commands',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Success({
          'ok': true,
          'commandId': 'cmd-3',
          'status': 'success',
          'data': {
            'countId': 'c1',
            'lineId': 'l1',
            'countedQuantity': 45,
            'expectedQuantity': 50,
            'difference': -5,
          },
        }),
      );

      final result = await countApi.setQuantity(
        commandId: 'cmd-3',
        countId: 'c1',
        lineId: 'l1',
        packages: 2,
        looseUnits: 5,
      );

      expect(result.isSuccess, isTrue);
      expect(result.countedQuantity, 45);

      final body =
          verify(
                () => apiClient.post<Map<String, dynamic>>(
                  '/m/api/commands',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body['type'], 'count_set');
      final payload = body['payload'] as Map<String, dynamic>;
      expect(payload['lineId'], 'l1');
      expect(payload['packages'], 2);
      expect(payload['looseUnits'], 5);
    });
  });

  group('isCountRetryableOffline', () {
    test('queues only network, timeout, and server failures', () {
      expect(isCountRetryableOffline(const NetworkException('down')), isTrue);
      expect(isCountRetryableOffline(const TimeoutException('slow')), isTrue);
      expect(
        isCountRetryableOffline(const ServerException('oops', statusCode: 500)),
        isTrue,
      );
      expect(
        isCountRetryableOffline(
          const ServerException('rate', statusCode: 429),
        ),
        isFalse,
      );
      expect(
        isCountRetryableOffline(const UnauthorizedException('expired')),
        isFalse,
      );
    });
  });
}
