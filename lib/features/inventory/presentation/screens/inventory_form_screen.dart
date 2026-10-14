import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/api/models/command.dart';
import '../../../scanner/presentation/widgets/barcode_scanner_dialog.dart';
import '../inventory_form_controller.dart';
import '../inventory_form_state.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  final String? initialBarcode;
  final CommandType initialType;

  const InventoryFormScreen({
    super.key,
    this.initialBarcode,
    this.initialType = CommandType.inventoryScan,
  });

  @override
  ConsumerState<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _quantityCtrl;
  late CommandType _selectedType;

  @override
  void initState() {
    super.initState();
    _barcodeCtrl = TextEditingController(text: widget.initialBarcode ?? '');
    _quantityCtrl = TextEditingController(text: '1');
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _adjustQuantity(int delta) {
    final current = int.tryParse(_quantityCtrl.text.trim()) ?? 1;
    final next = (current + delta).clamp(1, 999999);
    setState(() {
      _quantityCtrl.text = '$next';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(inventoryFormControllerProvider.notifier).submitInventory(
          type: _selectedType,
          barcode: _barcodeCtrl.text.trim(),
          quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inventoryFormControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحفظ في قائمة الانتظار'),
              backgroundColor: BaloraColors.success,
            ),
          );
          Navigator.of(context).pop();
        },
        error: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $msg'),
              backgroundColor: BaloraColors.error,
            ),
          );
        },
        orElse: () {},
      );
    });

    final state = ref.watch(inventoryFormControllerProvider);
    final isSaving = state.maybeWhen(saving: () => true, orElse: () => false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال مخزني يدوي'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<CommandType>(
                                    initialValue: _selectedType,
                                    decoration: const InputDecoration(
                                      labelText: 'نوع العملية',
                                      prefixIcon: Icon(
                                        Icons.assignment_outlined,
                                        color: BaloraColors.primary,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: CommandType.inventoryScan,
                                        child: Text('جرد المخزون'),
                                      ),
                                      DropdownMenuItem(
                                        value: CommandType.inventorySubmit,
                                        child: Text('استلام بضاعة'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedType = val);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _barcodeCtrl,
                                    textDirection: TextDirection.ltr,
                                    decoration: InputDecoration(
                                      labelText: 'الباركود',
                                      prefixIcon: const Icon(
                                        Icons.qr_code_rounded,
                                        color: BaloraColors.primary,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.qr_code_scanner_rounded,
                                          color: BaloraColors.primary,
                                        ),
                                        tooltip: 'مسح بالكاميرا',
                                        onPressed: () async {
                                          final code =
                                              await showBarcodeScannerDialog(
                                                context,
                                              );
                                          if (code != null && code.isNotEmpty) {
                                            setState(() {
                                              _barcodeCtrl.text = code;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'يرجى إدخال الباركود'
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _quantityCtrl,
                                          keyboardType: TextInputType.number,
                                          textDirection: TextDirection.ltr,
                                          decoration: const InputDecoration(
                                            labelText: 'الكمية',
                                            prefixIcon: Icon(
                                              Icons.numbers_rounded,
                                              color: BaloraColors.primary,
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'مطلوب';
                                            }
                                            final parsed = int.tryParse(v);
                                            if (parsed == null || parsed <= 0) {
                                              return 'رقم غير صحيح';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StepperButton(
                                        icon: Icons.remove_rounded,
                                        onTap: () => _adjustQuantity(-1),
                                      ),
                                      const SizedBox(width: 6),
                                      _StepperButton(
                                        icon: Icons.add_rounded,
                                        onTap: () => _adjustQuantity(1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: const Text('حفظ في قائمة الانتظار'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(46, 48),
        ),
        child: Icon(icon, size: 20, color: BaloraColors.textPrimary),
      ),
    );
  }
}
