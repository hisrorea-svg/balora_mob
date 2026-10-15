import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../../domain/count_models.dart';

/// The absolute quantity the operator typed: whole packages plus loose units.
typedef ManualQuantity = ({int packages, int looseUnits});

/// Bottom sheet that sets one line's counted quantity as packages + units;
/// the server owns the package-to-unit conversion.
class ManualQuantitySheet extends StatefulWidget {
  const ManualQuantitySheet({super.key, required this.line});

  final CountLine line;

  @override
  State<ManualQuantitySheet> createState() => _ManualQuantitySheetState();
}

class _ManualQuantitySheetState extends State<ManualQuantitySheet> {
  late final TextEditingController _packagesCtrl;
  late final TextEditingController _unitsCtrl;
  String? _error;

  /// When the package equals one unit the package box carries no meaning; it
  /// stays visible but inactive and the quantity lives in the units field.
  bool get _singleField => widget.line.unitsPerPackage <= 1;

  @override
  void initState() {
    super.initState();
    final counted = widget.line.countedQuantity;
    final factor = widget.line.unitsPerPackage > 0
        ? widget.line.unitsPerPackage
        : 1;
    if (_singleField) {
      _packagesCtrl = TextEditingController(text: '0');
      _unitsCtrl = TextEditingController(
        text: counted == null ? '' : '$counted',
      );
    } else {
      _packagesCtrl = TextEditingController(
        text: counted == null ? '0' : '${counted ~/ factor}',
      );
      _unitsCtrl = TextEditingController(
        text: counted == null ? '0' : '${counted % factor}',
      );
    }
  }

  @override
  void dispose() {
    _packagesCtrl.dispose();
    _unitsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final packages = _singleField ? 0 : int.tryParse(_packagesCtrl.text.trim());
    final units = int.tryParse(_unitsCtrl.text.trim());
    if (packages == null || units == null || packages < 0 || units < 0) {
      setState(() => _error = 'أدخل أعداداً صحيحة غير سالبة.');
      return;
    }
    Navigator.of(context).pop((packages: packages, looseUnits: units));
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              line.productName,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: BaloraColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              [
                if (line.batchNumber != null) 'دفعة ${line.batchNumber}',
                if (line.expiryDate != null) 'صلاحية ${line.expiryDate}',
                'المتوقع ${line.expectedQuantity}',
                'العلبة ${line.unitsPerPackage} وحدة',
              ].join(' · '),
              style: const TextStyle(
                fontSize: 11.5,
                color: BaloraColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _packagesCtrl,
                    enabled: !_singleField,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'علب',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text('+'),
                ),
                Expanded(
                  child: TextField(
                    controller: _unitsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'وحدات مفردة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: BaloraColors.error,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('حفظ الكمية'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
