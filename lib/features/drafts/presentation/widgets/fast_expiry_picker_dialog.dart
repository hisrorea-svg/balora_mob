import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

/// Parses pharmaceutical expiry shortcuts:
/// - 3 digits: e.g. "128" -> month 1, year 2028 -> DateTime(2028, 1, 1)
/// - 4 digits: e.g. "1228" -> month 12, year 2028 -> DateTime(2028, 12, 1)
/// - "0527" -> month 5, year 2027
/// - "1/28", "12/28", "03/2029", "2028-01"
DateTime? parsePharmaExpiry(String raw) {
  final clean = raw.trim().replaceAll(' ', '');
  if (clean.isEmpty) return null;

  // Handle slash or dash: e.g. 1/28, 12/28, 01/2028, 2028-01
  if (clean.contains('/') || clean.contains('-')) {
    final delimiter = clean.contains('/') ? '/' : '-';
    final parts = clean.split(delimiter);
    if (parts.length == 2) {
      final p1 = int.tryParse(parts[0]);
      final p2 = int.tryParse(parts[1]);
      if (p1 != null && p2 != null) {
        int month, year;
        if (p1 > 100) {
          // Format YYYY/MM
          year = p1;
          month = p2;
        } else {
          // Format MM/YY or MM/YYYY
          month = p1;
          year = p2 < 100 ? 2000 + p2 : p2;
        }
        if (month >= 1 && month <= 12 && year >= 2020 && year <= 2050) {
          return DateTime(year, month, 1);
        }
      }
    }
  }

  // Handle pure digits: e.g. 128 (1/28), 1228 (12/28), 0128 (01/28), 527 (5/27)
  final digits = clean.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 3) {
    // e.g. 128 -> month 1, year 28
    final month = int.tryParse(digits.substring(0, 1)) ?? 0;
    final yy = int.tryParse(digits.substring(1, 3)) ?? 0;
    final year = 2000 + yy;
    if (month >= 1 && month <= 9 && year >= 2020 && year <= 2050) {
      return DateTime(year, month, 1);
    }
  } else if (digits.length == 4) {
    // e.g. 1228 -> month 12, year 28 OR 0128 -> month 1, year 28
    final month = int.tryParse(digits.substring(0, 2)) ?? 0;
    final yy = int.tryParse(digits.substring(2, 4)) ?? 0;
    final year = 2000 + yy;
    if (month >= 1 && month <= 12 && year >= 2020 && year <= 2050) {
      return DateTime(year, month, 1);
    }
  } else if (digits.length == 5) {
    // e.g. 12028 -> month 1, year 2028
    final month = int.tryParse(digits.substring(0, 1)) ?? 0;
    final year = int.tryParse(digits.substring(1, 5)) ?? 0;
    if (month >= 1 && month <= 9 && year >= 2020 && year <= 2050) {
      return DateTime(year, month, 1);
    }
  } else if (digits.length == 6) {
    // e.g. 122028 -> month 12, year 2028
    final month = int.tryParse(digits.substring(0, 2)) ?? 0;
    final year = int.tryParse(digits.substring(2, 6)) ?? 0;
    if (month >= 1 && month <= 12 && year >= 2020 && year <= 2050) {
      return DateTime(year, month, 1);
    }
  }

  return null;
}

/// Formats a DateTime to MM/YYYY display string
String formatPharmaExpiry(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  return '$m/${date.year}';
}

/// Shows an ultra-fast pharmaceutical Month/Year picker
Future<DateTime?> showFastPharmaExpiryPicker({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FastExpiryPickerSheet(initialDate: initialDate),
  );
}

class _FastExpiryPickerSheet extends StatefulWidget {
  final DateTime? initialDate;

  const _FastExpiryPickerSheet({this.initialDate});

  @override
  State<_FastExpiryPickerSheet> createState() => _FastExpiryPickerSheetState();
}

class _FastExpiryPickerSheetState extends State<_FastExpiryPickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;

  static const _monthNames = [
    '01 - كانون 2 (Jan)',
    '02 - شباط (Feb)',
    '03 - آذار (Mar)',
    '04 - نيسان (Apr)',
    '05 - أيار (May)',
    '06 - حزيران (Jun)',
    '07 - تموز (Jul)',
    '08 - آب (Aug)',
    '09 - أيلول (Sep)',
    '10 - تشرين 1 (Oct)',
    '11 - تشرين 2 (Nov)',
    '12 - كانون 1 (Dec)',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final d = widget.initialDate ?? DateTime(now.year + 2, now.month);
    _selectedYear = d.year;
    _selectedMonth = d.month;
  }

  void _confirm(int month, int year) {
    Navigator.of(context).pop(DateTime(year, month, 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    final years = List.generate(8, (i) => currentYear + i); // e.g. 2026..2033

    return Container(
      decoration: const BoxDecoration(
        color: BaloraColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: BaloraColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: BaloraColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: BaloraColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'تحديد الصلاحية (شهر / سنة)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: BaloraColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Year Selection Pills
          const Text(
            'اختر السنة:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: BaloraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: years.map((y) {
                final isSelected = y == _selectedYear;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      '$y',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : BaloraColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: BaloraColors.primary,
                    backgroundColor: BaloraColors.surfaceSubtle,
                    onSelected: (val) {
                      if (val) setState(() => _selectedYear = y);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Month Selection Grid (1-tap to select month & confirm!)
          const Text(
            'اختر الشهر (يتم التأكيد فوراً بنقرة واحدة):',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: BaloraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected =
                  month == _selectedMonth && _selectedYear == (widget.initialDate?.year ?? now.year + 2);

              return Material(
                color: isSelected ? BaloraColors.primary : BaloraColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _confirm(month, _selectedYear),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? BaloraColors.primary
                            : BaloraColors.borderSubtle,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _monthNames[index],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : BaloraColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
