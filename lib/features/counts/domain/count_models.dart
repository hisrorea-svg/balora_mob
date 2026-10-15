/// Domain models for the mobile stock count flow (MS-4).
///
/// They mirror the frozen contract in `docs/mobile_stock_count_plan.md`
/// (Balora server repository): the open-drafts list, one count's snapshot,
/// and the command ACK payloads for `count_scan` / `count_set`.
library;

/// One open (draft) count in the phone's session site.
class ActiveCount {
  const ActiveCount({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.note,
    required this.createdAt,
    required this.total,
    required this.counted,
  });

  final String id;
  final String locationId;
  final String locationName;
  final String note;
  final DateTime? createdAt;
  final int total;
  final int counted;

  factory ActiveCount.fromJson(Map<String, dynamic> json) {
    return ActiveCount(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      total: (json['total'] as num?)?.toInt() ?? 0,
      counted: (json['counted'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One line inside a count snapshot.
class CountLine {
  const CountLine({
    required this.lineId,
    required this.productId,
    required this.productName,
    this.batchId,
    this.batchNumber,
    this.expiryDate,
    required this.unitsPerPackage,
    required this.expectedQuantity,
    this.countedQuantity,
    this.difference,
  });

  final String lineId;
  final String productId;
  final String productName;
  final String? batchId;
  final String? batchNumber;
  final String? expiryDate;
  final int unitsPerPackage;
  final int expectedQuantity;
  final int? countedQuantity;
  final int? difference;

  bool get isCounted => countedQuantity != null;
  bool get isMatched => difference == 0;

  CountLine copyWith({
    int? expectedQuantity,
    int? countedQuantity,
    bool clearCounted = false,
    int? difference,
    bool clearDifference = false,
  }) {
    return CountLine(
      lineId: lineId,
      productId: productId,
      productName: productName,
      batchId: batchId,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      unitsPerPackage: unitsPerPackage,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: clearCounted
          ? null
          : (countedQuantity ?? this.countedQuantity),
      difference: clearDifference ? null : (difference ?? this.difference),
    );
  }

  factory CountLine.fromJson(Map<String, dynamic> json) {
    return CountLine(
      lineId: json['lineId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      batchId: json['batchId'] as String?,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      unitsPerPackage: (json['unitsPerPackage'] as num?)?.toInt() ?? 1,
      expectedQuantity: (json['expectedQuantity'] as num?)?.toInt() ?? 0,
      countedQuantity: (json['countedQuantity'] as num?)?.toInt(),
      difference: (json['difference'] as num?)?.toInt(),
    );
  }
}

/// Server-computed KPI totals for one count.
class CountSummary {
  const CountSummary({
    required this.total,
    required this.counted,
    required this.matched,
    required this.variance,
  });

  final int total;
  final int counted;
  final int matched;
  final int variance;

  static const empty = CountSummary(
    total: 0,
    counted: 0,
    matched: 0,
    variance: 0,
  );

  factory CountSummary.fromJson(Map<String, dynamic> json) {
    return CountSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      counted: (json['counted'] as num?)?.toInt() ?? 0,
      matched: (json['matched'] as num?)?.toInt() ?? 0,
      variance: (json['variance'] as num?)?.toInt() ?? 0,
    );
  }

  /// Recomputes the KPI figures from locally updated lines so the screen
  /// stays live between server reads.
  factory CountSummary.fromLines(List<CountLine> lines) {
    var counted = 0;
    var matched = 0;
    var variance = 0;
    for (final line in lines) {
      if (!line.isCounted) continue;
      counted += 1;
      if (line.difference == 0) {
        matched += 1;
      } else {
        variance += 1;
      }
    }
    return CountSummary(
      total: lines.length,
      counted: counted,
      matched: matched,
      variance: variance,
    );
  }
}

/// One count's header, KPI totals, and current line page.
class CountSnapshot {
  const CountSnapshot({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.note,
    required this.status,
    required this.summary,
    required this.lines,
    required this.total,
  });

  final String id;
  final String locationId;
  final String locationName;
  final String note;
  final String status;
  final CountSummary summary;
  final List<CountLine> lines;
  final int total;

  bool get isDraft => status == 'draft';

  CountSnapshot withLines(List<CountLine> nextLines) {
    return CountSnapshot(
      id: id,
      locationId: locationId,
      locationName: locationName,
      note: note,
      status: status,
      summary: CountSummary.fromLines(nextLines),
      lines: nextLines,
      total: nextLines.length,
    );
  }

  factory CountSnapshot.fromJson(Map<String, dynamic> json) {
    final count = json['count'] as Map<String, dynamic>? ?? const {};
    final linesJson = json['lines'] as List<dynamic>? ?? const [];
    return CountSnapshot(
      id: count['id'] as String? ?? '',
      locationId: count['locationId'] as String? ?? '',
      locationName: count['locationName'] as String? ?? '',
      note: count['note'] as String? ?? '',
      status: count['status'] as String? ?? 'draft',
      summary: CountSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      lines: linesJson
          .whereType<Map<String, dynamic>>()
          .map(CountLine.fromJson)
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? linesJson.length,
    );
  }
}

/// One selectable batch when a scanned product has several active batches.
class CountBatchOption {
  const CountBatchOption({
    required this.batchId,
    this.batchNumber,
    this.expiryDate,
    required this.availableQuantity,
    this.countedQuantity,
    required this.expectedQuantity,
  });

  final String batchId;
  final String? batchNumber;
  final String? expiryDate;
  final int availableQuantity;
  final int? countedQuantity;
  final int expectedQuantity;

  factory CountBatchOption.fromJson(Map<String, dynamic> json) {
    return CountBatchOption(
      batchId: json['batchId'] as String? ?? '',
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      availableQuantity: (json['availableQuantity'] as num?)?.toInt() ?? 0,
      countedQuantity: (json['countedQuantity'] as num?)?.toInt(),
      expectedQuantity: (json['expectedQuantity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// The server ACK for one count command. Failures carry a stable [code] and an
/// Arabic [message]; successes carry the updated line in [data].
class CountCommandResult {
  const CountCommandResult({
    required this.commandId,
    required this.status,
    this.message,
    this.data = const {},
  });

  final String commandId;
  final String status;
  final String? message;
  final Map<String, dynamic> data;

  bool get isSuccess => status == 'success';

  String? get code => data['code'] as String?;
  String? get lineId => data['lineId'] as String?;
  String? get productId => data['productId'] as String?;
  String? get productName => data['productName'] as String?;
  String? get batchId => data['batchId'] as String?;
  String? get batchNumber => data['batchNumber'] as String?;
  String? get expiryDate => data['expiryDate'] as String?;
  int get unitsPerPackage => (data['unitsPerPackage'] as num?)?.toInt() ?? 1;
  int get expectedQuantity => (data['expectedQuantity'] as num?)?.toInt() ?? 0;
  int? get countedQuantity => (data['countedQuantity'] as num?)?.toInt();
  int? get difference => (data['difference'] as num?)?.toInt();

  List<CountBatchOption> get batchOptions {
    final raw = data['batches'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CountBatchOption.fromJson)
        .toList();
  }

  factory CountCommandResult.fromJson(Map<String, dynamic> json) {
    return CountCommandResult(
      commandId: json['commandId'] as String? ?? '',
      status: json['status'] as String? ?? 'failure',
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : const {},
    );
  }
}
