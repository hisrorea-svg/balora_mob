import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../scanner/domain/product.dart';
import '../../../scanner/presentation/widgets/barcode_scanner_dialog.dart';
import '../../data/drug_suggestion_service.dart';
import '../../domain/models/drug_suggestion.dart';
import '../product_form_controller.dart';
import '../product_form_state.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  final String? initialBarcode;

  const ProductFormScreen({super.key, this.product, this.initialBarcode});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _scientificNameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _manufacturerCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _costPriceCtrl;
  late final TextEditingController _countInBoxCtrl;
  late final TextEditingController _unitPriceCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _storageLocationCtrl;
  late final TextEditingController _descriptionCtrl;

  DateTime? _expiryDate;
  bool _isDivisible = true;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _isDivisible = p == null ? true : p.countInBox > 1;
    _barcodeCtrl = TextEditingController(
      text: p?.barcode ?? widget.initialBarcode ?? '',
    );
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _scientificNameCtrl = TextEditingController(text: p?.scientificName ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _manufacturerCtrl = TextEditingController(text: p?.manufacturer ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _costPriceCtrl = TextEditingController(
      text: p != null ? p.costPrice.toString() : '',
    );
    _countInBoxCtrl = TextEditingController(
      text: p != null ? p.countInBox.toString() : '1',
    );
    _unitPriceCtrl = TextEditingController(
      text: p != null ? p.unitPrice.toString() : '',
    );
    _quantityCtrl = TextEditingController(
      text: p != null ? p.quantity.toString() : '0',
    );
    _storageLocationCtrl = TextEditingController(
      text: p?.storageLocation ?? '',
    );
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _expiryDate = p?.expiryDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drugSuggestionServiceProvider).loadDrugs();
    });
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _scientificNameCtrl.dispose();
    _categoryCtrl.dispose();
    _manufacturerCtrl.dispose();
    _priceCtrl.dispose();
    _costPriceCtrl.dispose();
    _countInBoxCtrl.dispose();
    _unitPriceCtrl.dispose();
    _quantityCtrl.dispose();
    _storageLocationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    int countInBox = int.tryParse(_countInBoxCtrl.text) ?? 1;
    double unitPrice = double.tryParse(_unitPriceCtrl.text) ?? 0.0;

    if (!_isDivisible) {
      countInBox = 1;
      unitPrice = price;
    }

    final product = Product(
      barcode: _barcodeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      scientificName: _scientificNameCtrl.text.trim().isEmpty
          ? null
          : _scientificNameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim().isEmpty
          ? null
          : _manufacturerCtrl.text.trim(),
      price: price,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? 0.0,
      countInBox: countInBox,
      unitPrice: unitPrice,
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      expiryDate: _expiryDate,
      storageLocation: _storageLocationCtrl.text.trim().isEmpty
          ? null
          : _storageLocationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
    );

    ref
        .read(productFormControllerProvider.notifier)
        .submitProduct(isEdit: _isEdit, product: product);
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productFormControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEdit
                    ? 'تمت إضافة عملية تحديث المنتج للانتظار!'
                    : 'تمت إضافة عملية إنشاء المنتج للانتظار!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        },
        error: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $msg'), backgroundColor: Colors.red),
          );
        },
        orElse: () {},
      );
    });

    final state = ref.watch(productFormControllerProvider);
    final isSaving = state.maybeWhen(saving: () => true, orElse: () => false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.border),
        ),
        actions: [
          if (!isSaving)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: 'حفظ',
              onPressed: _submit,
            ),
        ],
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // ───────────── المعلومات الأساسية ─────────────
                        _buildSectionHeader(
                          context,
                          'المعلومات الأساسية',
                          Icons.info_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildNameAutocomplete(),
                        const SizedBox(height: 12),
                        _buildScientificNameAutocomplete(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildManufacturerAutocomplete()),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _categoryCtrl,
                                label: 'الفئة *',
                                icon: Icons.category,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _barcodeCtrl,
                          label: 'الباركود *',
                          enabled: !_isEdit,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'مطلوب' : null,
                          suffixIcon: !_isEdit
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: BaloraColors.primary,
                                  ),
                                  onPressed: () async {
                                    final barcode =
                                        await showBarcodeScannerDialog(context);
                                    if (barcode != null && barcode.isNotEmpty) {
                                      setState(() {
                                        _barcodeCtrl.text = barcode;
                                      });
                                    }
                                  },
                                )
                              : null,
                        ),

                        const SizedBox(height: 24),
                        // ───────────── الأسعار والتقسيم ─────────────
                        _buildSectionHeader(
                          context,
                          'الأسعار والتقسيم',
                          Icons.attach_money,
                          action: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'يوجد تقسيم',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isDivisible
                                      ? BaloraColors.primary
                                      : Colors.grey,
                                ),
                              ),
                              Switch(
                                value: _isDivisible,
                                onChanged: (val) =>
                                    setState(() => _isDivisible = val),
                                activeTrackColor: BaloraColors.primary
                                    .withValues(alpha: 0.5),
                                activeThumbColor: BaloraColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _costPriceCtrl,
                                label: _isDivisible
                                    ? 'سعر الشراء (علبة) *'
                                    : 'سعر الشراء *',
                                icon: Icons.money_off,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            if (_isDivisible) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _countInBoxCtrl,
                                  label: 'العدد في العلبة *',
                                  icon: Icons.inventory_2,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'مطلوب' : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _priceCtrl,
                                label: _isDivisible
                                    ? 'سعر البيع (علبة) *'
                                    : 'سعر البيع *',
                                icon: Icons.attach_money,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            if (_isDivisible) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _unitPriceCtrl,
                                  label: 'سعر البيع (وحدة) *',
                                  icon: Icons.sell,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'مطلوب' : null,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),
                        // ───────────── المخزون والكميات ─────────────
                        _buildSectionHeader(
                          context,
                          'المخزون والكميات',
                          Icons.warehouse,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _quantityCtrl,
                                label: 'الكمية الافتتاحية (علبة)',
                                icon: Icons.inventory,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _pickExpiryDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'تاريخ الانتهاء *',
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                      color: BaloraColors.primary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: BaloraColors.textSecondary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _expiryDate != null
                                        ? '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}'
                                        : 'اختر التاريخ',
                                    style: TextStyle(
                                      color: _expiryDate != null
                                          ? null
                                          : BaloraColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _storageLocationCtrl,
                          label: 'موقع التخزين',
                          icon: Icons.place,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _descriptionCtrl,
                          label: 'ملاحظات',
                          icon: Icons.description,
                          maxLines: 2,
                        ),

                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(
                            _isEdit ? Icons.save_outlined : Icons.add_rounded,
                          ),
                          label: Text(_isEdit ? 'حفظ التغييرات' : 'حفظ المنتج'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, color: BaloraColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: BaloraColors.primary,
            ),
          ),
        ),
        ?action,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: BaloraColors.primary)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: BaloraColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNameAutocomplete() {
    return Autocomplete<DrugSuggestion>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<DrugSuggestion>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchByName(textEditingValue.text);
      },
      displayStringForOption: (DrugSuggestion option) => option.name,
      onSelected: (DrugSuggestion selection) {
        setState(() {
          _nameCtrl.text = selection.name;
          if (_scientificNameCtrl.text.isEmpty &&
              selection.scientificName != null) {
            _scientificNameCtrl.text = selection.scientificName!;
          }
          if (_manufacturerCtrl.text.isEmpty &&
              selection.manufacturer != null) {
            _manufacturerCtrl.text = selection.manufacturer!;
          }
          if (_categoryCtrl.text.isEmpty && selection.category != null) {
            _categoryCtrl.text = selection.category!;
          }
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != _nameCtrl.text) {
          controller.text = _nameCtrl.text;
        }

        _nameCtrl.addListener(() {
          if (controller.text != _nameCtrl.text) {
            controller.text = _nameCtrl.text;
          }
        });
        controller.addListener(() {
          if (_nameCtrl.text != controller.text) {
            _nameCtrl.text = controller.text;
          }
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'اسم المنتج *',
            prefixIcon: const Icon(
              Icons.medication,
              color: BaloraColors.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: BaloraColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(
                  240.0,
                  520.0,
                ),
                maxHeight: 220,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: option.scientificName != null
                        ? Text(
                            option.scientificName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScientificNameAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchScientificNames(textEditingValue.text);
      },
      onSelected: (String selection) {
        _scientificNameCtrl.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != _scientificNameCtrl.text) {
          controller.text = _scientificNameCtrl.text;
        }

        _scientificNameCtrl.addListener(() {
          if (controller.text != _scientificNameCtrl.text) {
            controller.text = _scientificNameCtrl.text;
          }
        });
        controller.addListener(() {
          if (_scientificNameCtrl.text != controller.text) {
            _scientificNameCtrl.text = controller.text;
          }
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الاسم العلمي',
            prefixIcon: const Icon(Icons.science, color: BaloraColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: BaloraColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  Widget _buildManufacturerAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchCompanies(textEditingValue.text);
      },
      onSelected: (String selection) {
        _manufacturerCtrl.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != _manufacturerCtrl.text) {
          controller.text = _manufacturerCtrl.text;
        }

        _manufacturerCtrl.addListener(() {
          if (controller.text != _manufacturerCtrl.text) {
            controller.text = _manufacturerCtrl.text;
          }
        });
        controller.addListener(() {
          if (_manufacturerCtrl.text != controller.text) {
            _manufacturerCtrl.text = controller.text;
          }
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الشركة المصنعة',
            prefixIcon: const Icon(Icons.business, color: BaloraColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: BaloraColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}
