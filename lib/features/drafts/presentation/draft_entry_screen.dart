import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../products/data/drug_suggestion_service.dart';
import '../../products/domain/models/drug_suggestion.dart';
import '../../scanner/domain/product.dart';
import '../../scanner/presentation/widgets/barcode_scanner_dialog.dart';
import '../domain/draft_product.dart';
import 'draft_entry_controller.dart';
import 'draft_entry_state.dart';
import 'widgets/continuous_mode_banner.dart';
import 'widgets/fast_expiry_picker_dialog.dart';

/// Screen for receiving supplier invoices / goods receipt (كارت استلام بضاعة).
/// Strictly aligned with Balora Desktop "استلام فاتورة مورد" sequence, inputs,
/// and business logic.
class DraftEntryScreen extends ConsumerStatefulWidget {
  final String? initialBarcode;
  final bool isSingleItem;

  const DraftEntryScreen({
    super.key,
    this.initialBarcode,
    this.isSingleItem = false,
  });

  @override
  ConsumerState<DraftEntryScreen> createState() => _DraftEntryScreenState();
}

class _DraftEntryScreenState extends ConsumerState<DraftEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Barcode & Identification
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _nameArCtrl;

  // 2. Purchase Unit & Packaging (Desktop: الشراء [ علبة | وحدة ] + داخل العلبة)
  String _purchaseUnit = 'box'; // 'box' or 'unit'
  late final TextEditingController _stripsPerBoxCtrl;

  // 3. Quantities & Cost (Desktop: العدد + بونص + سعر الشراء + المجموع)
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _bonusCtrl;
  late final TextEditingController _costPriceBoxCtrl;
  late final TextEditingController _costPriceUnitCtrl;

  // 4. Expiry & Batch (Desktop: الصلاحية + رقم الدفعة)
  final TextEditingController _expiryCtrl = TextEditingController();
  late final TextEditingController _batchNumberCtrl;
  late final TextEditingController _shelfLocationCtrl;
  late final TextEditingController _notesCtrl;

  // 5. New Product Details & Selling Prices (Desktop Step 2: الأصناف الجديدة)
  bool _showNewProductFields = false;
  late final TextEditingController _sellPriceBoxCtrl;
  late final TextEditingController _sellPriceUnitCtrl;
  late final TextEditingController _stripBarcodeCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _scientificNameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _dosageFormCtrl;
  late final TextEditingController _manufacturerCtrl;

  // Focus Nodes
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _bonusFocusNode = FocusNode();
  final FocusNode _stripsFocusNode = FocusNode();
  final FocusNode _costPriceFocusNode = FocusNode();
  final FocusNode _expiryFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _scientificNameFocusNode = FocusNode();
  final FocusNode _manufacturerFocusNode = FocusNode();

  DateTime? _expiryDate;
  bool _continuousMode = false;
  bool _isCheckingBarcode = false;
  bool _isRecalculating = false;

  @override
  void initState() {
    super.initState();
    _continuousMode = !widget.isSingleItem;
    _barcodeCtrl = TextEditingController(text: widget.initialBarcode ?? '');
    _nameArCtrl = TextEditingController();

    _stripsPerBoxCtrl = TextEditingController(text: '1');
    _quantityCtrl = TextEditingController(text: '1');
    _bonusCtrl = TextEditingController(text: '0');

    _costPriceBoxCtrl = TextEditingController();
    _costPriceUnitCtrl = TextEditingController();
    _sellPriceBoxCtrl = TextEditingController();
    _sellPriceUnitCtrl = TextEditingController();

    _batchNumberCtrl = TextEditingController();
    _shelfLocationCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    _stripBarcodeCtrl = TextEditingController();
    _nameEnCtrl = TextEditingController();
    _scientificNameCtrl = TextEditingController();
    _categoryCtrl = TextEditingController(text: 'أدوية');
    _dosageFormCtrl = TextEditingController();
    _manufacturerCtrl = TextEditingController();

    // Auto-select text on focus
    _quantityFocusNode.addListener(() {
      if (_quantityFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_quantityCtrl.text.isNotEmpty) {
            _quantityCtrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _quantityCtrl.text.length,
            );
          }
        });
      }
    });

    _bonusFocusNode.addListener(() {
      if (_bonusFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_bonusCtrl.text.isNotEmpty) {
            _bonusCtrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _bonusCtrl.text.length,
            );
          }
        });
      }
    });

    _stripsFocusNode.addListener(() {
      if (_stripsFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_stripsPerBoxCtrl.text.isNotEmpty) {
            _stripsPerBoxCtrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _stripsPerBoxCtrl.text.length,
            );
          }
        });
      }
    });

    _costPriceFocusNode.addListener(() {
      if (_costPriceFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctrl = _purchaseUnit == 'box' ? _costPriceBoxCtrl : _costPriceUnitCtrl;
          if (ctrl.text.isNotEmpty) {
            ctrl.selection = TextSelection(
              baseOffset: 0,
              extentOffset: ctrl.text.length,
            );
          }
        });
      }
    });

    _expiryFocusNode.addListener(() {
      if (!_expiryFocusNode.hasFocus) {
        final parsed = parsePharmaExpiry(_expiryCtrl.text);
        if (parsed != null) {
          _expiryDate = parsed;
          _expiryCtrl.text = formatPharmaExpiry(parsed);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drugSuggestionServiceProvider).loadDrugs();
      if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
        _onBarcodeChanged(widget.initialBarcode!);
      }
    });
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _bonusFocusNode.dispose();
    _stripsFocusNode.dispose();
    _costPriceFocusNode.dispose();
    _expiryFocusNode.dispose();
    _nameFocusNode.dispose();
    _scientificNameFocusNode.dispose();
    _manufacturerFocusNode.dispose();

    _barcodeCtrl.dispose();
    _nameArCtrl.dispose();
    _stripsPerBoxCtrl.dispose();
    _quantityCtrl.dispose();
    _bonusCtrl.dispose();
    _costPriceBoxCtrl.dispose();
    _costPriceUnitCtrl.dispose();
    _sellPriceBoxCtrl.dispose();
    _sellPriceUnitCtrl.dispose();
    _batchNumberCtrl.dispose();
    _shelfLocationCtrl.dispose();
    _notesCtrl.dispose();
    _expiryCtrl.dispose();
    _stripBarcodeCtrl.dispose();
    _nameEnCtrl.dispose();
    _scientificNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dosageFormCtrl.dispose();
    _manufacturerCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double val) {
    if (val <= 0) return '';
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  double _calculateLineTotal() {
    final qty = int.tryParse(_quantityCtrl.text) ?? 0;
    if (_purchaseUnit == 'box') {
      final boxCost = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
      return qty * boxCost;
    } else {
      final unitCost = double.tryParse(_costPriceUnitCtrl.text) ??
          (double.tryParse(_costPriceBoxCtrl.text) ?? 0.0);
      return qty * unitCost;
    }
  }

  void _onPurchaseCostChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final cost = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;

    if (_purchaseUnit == 'box') {
      _costPriceBoxCtrl.text = val;
      if (strips > 0) {
        _costPriceUnitCtrl.text = _formatPrice(cost / strips);
      }
    } else {
      _costPriceUnitCtrl.text = val;
      if (strips > 0) {
        _costPriceBoxCtrl.text = _formatPrice(cost * strips);
      }
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onBoxSellChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final boxSell = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips > 0) {
      _sellPriceUnitCtrl.text = _formatPrice(boxSell / strips);
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onUnitSellChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final unitSell = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips > 0) {
      _sellPriceBoxCtrl.text = _formatPrice(unitSell * strips);
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onStripsChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final strips = int.tryParse(val) ?? 1;
    if (strips > 0) {
      final boxCost = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
      if (boxCost > 0) {
        _costPriceUnitCtrl.text = _formatPrice(boxCost / strips);
      }
      final boxSell = double.tryParse(_sellPriceBoxCtrl.text) ?? 0.0;
      if (boxSell > 0) {
        _sellPriceUnitCtrl.text = _formatPrice(boxSell / strips);
      }
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onPurchaseUnitChanged(String unit) {
    if (_purchaseUnit == unit) return;
    setState(() {
      _purchaseUnit = unit;
      final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
      if (unit == 'unit') {
        final boxCost = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
        if (boxCost > 0 && strips > 0 && (_costPriceUnitCtrl.text.isEmpty || _costPriceUnitCtrl.text == '0')) {
          _costPriceUnitCtrl.text = _formatPrice(boxCost / strips);
        }
      } else {
        final unitCost = double.tryParse(_costPriceUnitCtrl.text) ?? 0.0;
        if (unitCost > 0 && strips > 0 && (_costPriceBoxCtrl.text.isEmpty || _costPriceBoxCtrl.text == '0')) {
          _costPriceBoxCtrl.text = _formatPrice(unitCost * strips);
        }
      }
    });
  }

  Future<void> _onBarcodeChanged(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return;

    setState(() => _isCheckingBarcode = true);

    final checkResult = await ref
        .read(draftEntryControllerProvider.notifier)
        .checkBarcode(cleanBarcode);

    if (!mounted) return;
    setState(() => _isCheckingBarcode = false);

    switch (checkResult) {
      case BarcodeFoundInPharmacy(:final product):
        _populateFromProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: BaloraColors.primary,
              content: Text(
                'تم استرجاع بيانات الصنف (${product.name}) تلقائياً من الصيدلية',
              ),
            ),
          );
        }

      case BarcodeFoundInReference(:final suggestion):
        _populateFromDrugSuggestion(suggestion);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: BaloraColors.primary,
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تم ملء بيانات (${suggestion.name}) تلقائياً من المرجع الدوائي!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

      case BarcodeNotFound():
        // Unknown barcode, open new product details
        setState(() => _showNewProductFields = true);
        break;
    }
  }

  void _populateFromProduct(Product product) {
    setState(() {
      _nameArCtrl.text = product.name;
      if (_barcodeCtrl.text.trim().isEmpty && product.barcode.isNotEmpty) {
        _barcodeCtrl.text = product.barcode;
      }
      if (product.nameEn != null && product.nameEn!.isNotEmpty) {
        _nameEnCtrl.text = product.nameEn!;
      }
      if (product.scientificName != null && product.scientificName!.isNotEmpty) {
        _scientificNameCtrl.text = product.scientificName!;
      }
      if (product.category.isNotEmpty) {
        _categoryCtrl.text = product.category;
      }
      if (product.manufacturer != null && product.manufacturer!.isNotEmpty) {
        _manufacturerCtrl.text = product.manufacturer!;
      }
      if (product.stripBarcode != null && product.stripBarcode!.isNotEmpty) {
        _stripBarcodeCtrl.text = product.stripBarcode!;
      }
      final strips = product.countInBox > 0 ? product.countInBox : 1;
      _stripsPerBoxCtrl.text = strips.toString();

      if (product.costPrice > 0) {
        _costPriceBoxCtrl.text = product.costPrice.toStringAsFixed(0);
        _costPriceUnitCtrl.text = _formatPrice(product.costPrice / strips);
      } else if (product.costPriceUnit != null && product.costPriceUnit! > 0) {
        _costPriceUnitCtrl.text = product.costPriceUnit!.toStringAsFixed(0);
        _costPriceBoxCtrl.text = _formatPrice(product.costPriceUnit! * strips);
      }
      if (product.price > 0) {
        _sellPriceBoxCtrl.text = product.price.toStringAsFixed(0);
        _sellPriceUnitCtrl.text = _formatPrice(product.price / strips);
      } else if (product.unitPrice > 0) {
        _sellPriceUnitCtrl.text = product.unitPrice.toStringAsFixed(0);
        _sellPriceBoxCtrl.text = _formatPrice(product.unitPrice * strips);
      }
      _onStripsChanged(strips.toString());
      if (product.storageLocation != null && product.storageLocation!.isNotEmpty) {
        _shelfLocationCtrl.text = product.storageLocation!;
      }
    });
  }

  void _populateFromDrugSuggestion(DrugSuggestion suggestion) {
    setState(() {
      _nameArCtrl.text = suggestion.name;
      if (suggestion.barcode != null &&
          suggestion.barcode!.trim().isNotEmpty &&
          _barcodeCtrl.text.trim().isEmpty) {
        _barcodeCtrl.text = suggestion.barcode!.trim();
      }
      if (suggestion.scientificName != null && suggestion.scientificName!.isNotEmpty) {
        _scientificNameCtrl.text = suggestion.scientificName!;
      }
      if (suggestion.manufacturer != null && suggestion.manufacturer!.isNotEmpty) {
        _manufacturerCtrl.text = suggestion.manufacturer!;
      }
      if (suggestion.category != null && suggestion.category!.isNotEmpty) {
        _categoryCtrl.text = suggestion.category!;
      }
      if (suggestion.dosageForm != null && suggestion.dosageForm!.isNotEmpty) {
        _dosageFormCtrl.text = suggestion.dosageForm!;
      }
      final strips = (suggestion.stripsPerBox != null && suggestion.stripsPerBox! > 0)
          ? suggestion.stripsPerBox!
          : 1;
      _stripsPerBoxCtrl.text = strips.toString();

      if (suggestion.suggestedCost != null && suggestion.suggestedCost! > 0) {
        _costPriceBoxCtrl.text = suggestion.suggestedCost!.toStringAsFixed(0);
        _costPriceUnitCtrl.text = _formatPrice(suggestion.suggestedCost! / strips);
      }
      if (suggestion.suggestedPrice != null && suggestion.suggestedPrice! > 0) {
        _sellPriceBoxCtrl.text = suggestion.suggestedPrice!.toStringAsFixed(0);
        _sellPriceUnitCtrl.text = _formatPrice(suggestion.suggestedPrice! / strips);
      }
      _onStripsChanged(strips.toString());
    });
  }

  void _resetForm() {
    _barcodeCtrl.clear();
    _stripBarcodeCtrl.clear();
    _nameArCtrl.clear();
    _nameEnCtrl.clear();
    _scientificNameCtrl.clear();
    _dosageFormCtrl.clear();
    _manufacturerCtrl.clear();
    _costPriceBoxCtrl.clear();
    _sellPriceBoxCtrl.clear();
    _stripsPerBoxCtrl.text = '1';
    _costPriceUnitCtrl.clear();
    _sellPriceUnitCtrl.clear();
    _quantityCtrl.text = '1';
    _bonusCtrl.text = '0';
    _purchaseUnit = 'box';
    _batchNumberCtrl.clear();
    _shelfLocationCtrl.clear();
    _notesCtrl.clear();
    _expiryCtrl.clear();
    _expiryDate = null;
    _showNewProductFields = false;
    setState(() {});
  }

  Future<void> _openFastExpiryPicker() async {
    final picked = await showFastPharmaExpiryPicker(
      context: context,
      initialDate: _expiryDate,
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryCtrl.text = formatPharmaExpiry(picked);
      });
    }
  }

  Future<void> _submit({required bool stayInContinuous}) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تصحيح الحقول المطلوبة باللون الأحمر'),
          backgroundColor: BaloraColors.error,
        ),
      );
      return;
    }

    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    double boxCost = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
    double unitCost = double.tryParse(_costPriceUnitCtrl.text) ?? 0.0;

    if (_purchaseUnit == 'box') {
      if (unitCost == 0.0 && strips > 0 && boxCost > 0) {
        unitCost = boxCost / strips;
      }
    } else {
      if (boxCost == 0.0 && strips > 0 && unitCost > 0) {
        boxCost = unitCost * strips;
      }
    }

    final boxSell = double.tryParse(_sellPriceBoxCtrl.text) ?? 0.0;
    final unitSell = double.tryParse(_sellPriceUnitCtrl.text) ??
        (strips > 0 ? (boxSell / strips) : 0.0);
    final quantity = int.tryParse(_quantityCtrl.text) ?? 0;
    final bonus = int.tryParse(_bonusCtrl.text) ?? 0;

    final parsedExp = parsePharmaExpiry(_expiryCtrl.text);
    final effectiveExpiry = parsedExp ?? _expiryDate;
    String? formattedExpiry;
    if (effectiveExpiry != null) {
      final y = effectiveExpiry.year.toString();
      final m = effectiveExpiry.month.toString().padLeft(2, '0');
      formattedExpiry = '$y-$m';
    }

    final draft = DraftProduct(
      barcode: _barcodeCtrl.text.trim(),
      stripBarcode: _stripBarcodeCtrl.text.trim().isEmpty
          ? null
          : _stripBarcodeCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      nameEn: _nameEnCtrl.text.trim().isEmpty ? null : _nameEnCtrl.text.trim(),
      scientificName: _scientificNameCtrl.text.trim().isEmpty
          ? null
          : _scientificNameCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'أدوية'
          : _categoryCtrl.text.trim(),
      dosageForm: _dosageFormCtrl.text.trim().isEmpty
          ? null
          : _dosageFormCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim().isEmpty
          ? null
          : _manufacturerCtrl.text.trim(),
      costPriceBox: boxCost,
      sellPriceBox: boxSell,
      stripsPerBox: strips,
      costPriceUnit: unitCost,
      sellPriceUnit: unitSell,
      quantity: quantity,
      bonus: bonus,
      purchaseUnit: _purchaseUnit,
      quantityUnit: _purchaseUnit,
      batchNumber: _batchNumberCtrl.text.trim().isEmpty
          ? null
          : _batchNumberCtrl.text.trim(),
      expiryDate: formattedExpiry,
      shelfLocation: _shelfLocationCtrl.text.trim().isEmpty
          ? null
          : _shelfLocationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final result = await ref
        .read(draftEntryControllerProvider.notifier)
        .submitDraft(draft);

    if (!mounted) return;

    if (result != null) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: BaloraColors.success,
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.isSingleItem
                      ? 'تم حفظ الصنف: ${draft.nameAr} بنجاح'
                      : 'تم حفظ سطر الفاتورة: ${draft.nameAr} في طابور المراجعة',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );

      if (!widget.isSingleItem && stayInContinuous && _continuousMode) {
        _resetForm();
        final nextBarcode = await showBarcodeScannerDialog(context);
        if (nextBarcode != null && nextBarcode.isNotEmpty && mounted) {
          _barcodeCtrl.text = nextBarcode;
          _onBarcodeChanged(nextBarcode);
        }
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(draftEntryControllerProvider);
    final isSaving = state.maybeWhen(saving: () => true, orElse: () => false);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final lineTotal = _calculateLineTotal();

    return Scaffold(
      backgroundColor: BaloraColors.surface,
      appBar: AppBar(
        title: Text(
          widget.isSingleItem ? 'إضافة صنف جديد' : 'استلام فاتورة مورد (وارد المخزن)',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: BaloraColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isSaving)
            IconButton(
              tooltip: widget.isSingleItem ? 'حفظ الصنف' : 'حفظ كمسودة',
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _submit(stayInContinuous: !widget.isSingleItem && _continuousMode),
            ),
          IconButton(
            tooltip: 'تفريغ الحقول',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: isSaving ? null : _resetForm,
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  isKeyboardOpen ? 24 : 110,
                ),
                children: [
                  // Continuous Mode Switch Banner
                  if (!widget.isSingleItem) ...[
                    ContinuousModeBanner(
                      isEnabled: _continuousMode,
                      onToggle: (val) {
                        setState(() => _continuousMode = val);
                        HapticFeedback.selectionClick();
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  // CARD 1: المادة والتعبئة (Desktop: المادة + الشراء [علبة / وحدة] + داخل العلبة)
                  _buildSectionCard(
                    number: '1',
                    title: 'المادة والتعبئة',
                    accentColor: const Color(0xFF0D5C75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Barcode
                        TextFormField(
                          controller: _barcodeCtrl,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'باركود العلبة (الرئيسي) *',
                            hintText: 'امسح أو اكتب الباركود',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isCheckingBarcode)
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: BaloraColors.primary,
                                  ),
                                  tooltip: 'مسح بالكاميرا',
                                  onPressed: () async {
                                    final scanned = await showBarcodeScannerDialog(context);
                                    if (scanned != null && scanned.isNotEmpty) {
                                      _barcodeCtrl.text = scanned;
                                      _onBarcodeChanged(scanned);
                                    }
                                  },
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          onFieldSubmitted: _onBarcodeChanged,
                        ),

                        const SizedBox(height: 12),

                        // Trade Name with Drug Suggestions Autocomplete (safe & isolated scroll)
                        _buildTradeNameAutocomplete(),

                        const SizedBox(height: 14),

                        // Purchase Unit Toggle & Count In Box
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Desktop-like Segmented Button: الشراء [ علبة | وحدة ]
                            Expanded(
                              flex: _purchaseUnit == 'box' ? 3 : 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'وحدة الشراء بالفاتورة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: BaloraColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: BaloraColors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: BaloraColors.borderSubtle),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _onPurchaseUnitChanged('box'),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _purchaseUnit == 'box'
                                                    ? BaloraColors.primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'علبة',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _purchaseUnit == 'box'
                                                      ? Colors.white
                                                      : BaloraColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _onPurchaseUnitChanged('unit'),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _purchaseUnit == 'unit'
                                                    ? BaloraColors.primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'وحدة',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _purchaseUnit == 'unit'
                                                      ? Colors.white
                                                      : BaloraColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_purchaseUnit == 'box') ...[
                              const SizedBox(width: 12),
                              // داخل العلبة (Default 1)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'داخل العلبة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: BaloraColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _stripsPerBoxCtrl,
                                      focusNode: _stripsFocusNode,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        hintText: '1',
                                        suffixText: 'وحدة',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      ),
                                      onChanged: _onStripsChanged,
                                      validator: (v) {
                                        if (_purchaseUnit != 'box') return null;
                                        final val = int.tryParse(v ?? '');
                                        if (val == null || val < 1) return '>= 1';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARD 2: كميات الفاتورة والتكلفة (Desktop: العدد + بونص + سعر الشراء + المجموع)
                  _buildSectionCard(
                    number: '2',
                    title: 'كميات الفاتورة والتكلفة (المجموع)',
                    accentColor: const Color(0xFF10B981),
                    child: Column(
                      children: [
                        // Row: العدد + بونص
                        Row(
                          children: [
                            // العدد
                            Expanded(
                              child: TextFormField(
                                controller: _quantityCtrl,
                                focusNode: _quantityFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'العدد (الكمية) *',
                                  hintText: '1',
                                  suffixText: _purchaseUnit == 'box' ? 'علبة' : 'وحدة',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                                  if (int.tryParse(v) == null) return 'رقم غير صحيح';
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // بونص
                            Expanded(
                              child: TextFormField(
                                controller: _bonusCtrl,
                                focusNode: _bonusFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'بونص (مجاني)',
                                  hintText: '0',
                                  suffixText: _purchaseUnit == 'box' ? 'علبة' : 'وحدة',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // سعر الشراء
                        TextFormField(
                          controller: _purchaseUnit == 'box' ? _costPriceBoxCtrl : _costPriceUnitCtrl,
                          focusNode: _costPriceFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          decoration: InputDecoration(
                            labelText: _purchaseUnit == 'box'
                                ? 'سعر شراء العلبة *'
                                : 'سعر شراء الوحدة *',
                            hintText: 'سعر الفاتورة',
                            suffixText: 'د.ع',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          onChanged: _onPurchaseCostChanged,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'مطلوب';
                            if (double.tryParse(v) == null) return 'غير صحيح';
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // شريط المجموع الفوري (Live Row Total)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: BaloraColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BaloraColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_rounded,
                                color: BaloraColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'المجموع: ${_formatPrice(lineTotal)} د.ع',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: BaloraColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'الكمية: ${_quantityCtrl.text.isEmpty ? '0' : _quantityCtrl.text} ${_purchaseUnit == 'box' ? 'علبة' : 'وحدة'}'
                                      '${(int.tryParse(_bonusCtrl.text) ?? 0) > 0 ? ' + ${_bonusCtrl.text} بونص' : ''}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: BaloraColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARD 3: الصلاحية والتشغيلة (Desktop: الصلاحية + رقم الدفعة)
                  _buildSectionCard(
                    number: '3',
                    title: 'الصلاحية ورقم الدفعة',
                    accentColor: const Color(0xFFD97706),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // الصلاحية
                            Expanded(
                              child: TextFormField(
                                controller: _expiryCtrl,
                                focusNode: _expiryFocusNode,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'الصلاحية *',
                                  hintText: 'مثال: 0127',
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: BaloraColors.primary,
                                    ),
                                    tooltip: 'اختيار سريع للشهر والسنة',
                                    onPressed: _openFastExpiryPicker,
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                                onChanged: (val) {
                                  final digits = val.replaceAll(RegExp(r'\D'), '');
                                  bool shouldAutoFormat = false;

                                  if (digits.length == 3) {
                                    final firstDigit = int.tryParse(digits[0]) ?? 0;
                                    final thirdDigit = int.tryParse(digits[2]) ?? 0;
                                    if (firstDigit > 1 || thirdDigit != 2) {
                                      shouldAutoFormat = true;
                                    }
                                  } else if (digits.length >= 4 && !val.contains('/')) {
                                    shouldAutoFormat = true;
                                  }

                                  if (shouldAutoFormat) {
                                    final parsed = parsePharmaExpiry(digits);
                                    if (parsed != null) {
                                      _expiryDate = parsed;
                                      final formatted = formatPharmaExpiry(parsed);
                                      _expiryCtrl.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(offset: formatted.length),
                                      );
                                      return;
                                    }
                                  }

                                  final parsed = parsePharmaExpiry(val);
                                  if (parsed != null) {
                                    _expiryDate = parsed;
                                  }
                                },
                                onFieldSubmitted: (val) {
                                  final parsed = parsePharmaExpiry(val);
                                  if (parsed != null) {
                                    setState(() {
                                      _expiryDate = parsed;
                                      _expiryCtrl.text = formatPharmaExpiry(parsed);
                                    });
                                  }
                                },
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                                  final parsed = parsePharmaExpiry(v);
                                  if (parsed == null) return 'غير صحيح (0127)';
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // رقم الدفعة
                            Expanded(
                              child: TextFormField(
                                controller: _batchNumberCtrl,
                                decoration: InputDecoration(
                                  labelText: 'رقم الدفعة (اختياري)',
                                  hintText: 'e.g. B2409',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _shelfLocationCtrl,
                                decoration: InputDecoration(
                                  labelText: 'موقع الرف (اختياري)',
                                  hintText: 'مثال: A-3',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _notesCtrl,
                                decoration: InputDecoration(
                                  labelText: 'ملاحظات (اختياري)',
                                  hintText: 'عرض خاص...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARD 4: بيانات الصنف الجديد وتسعير البيع (Desktop Step 2: الأصناف الجديدة)
                  Container(
                    decoration: BoxDecoration(
                      color: BaloraColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: BaloraColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _showNewProductFields = !_showNewProductFields),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '4',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'بيانات الصنف الجديد وسعر البيع',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: BaloraColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showNewProductFields
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: BaloraColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showNewProductFields) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                // Selling prices
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _sellPriceBoxCtrl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'سعر بيع العلبة',
                                          suffixText: 'د.ع',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        ),
                                        onChanged: _onBoxSellChanged,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _sellPriceUnitCtrl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'سعر بيع الوحدة',
                                          suffixText: 'د.ع',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        ),
                                        onChanged: _onUnitSellChanged,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Strip barcode
                                TextFormField(
                                  controller: _stripBarcodeCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'باركود الوحدة (اختياري)',
                                    hintText: 'للبيع بالتجزئة بالوحدة',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined, color: BaloraColors.primary),
                                      onPressed: () async {
                                        final scanned = await showBarcodeScannerDialog(context);
                                        if (scanned != null && scanned.isNotEmpty) {
                                          setState(() => _stripBarcodeCtrl.text = scanned);
                                        }
                                      },
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // English Name
                                TextFormField(
                                  controller: _nameEnCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم بالإنجليزية (للطباعة الحرارية)',
                                    hintText: 'e.g. Augmentin 1g',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Scientific Name Autocomplete
                                _buildScientificNameAutocomplete(),

                                const SizedBox(height: 12),

                                // Dosage Form & Category
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _dosageFormCtrl,
                                        decoration: InputDecoration(
                                          labelText: 'الشكل الصيدلاني',
                                          hintText: 'حبوب، شراب...',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _categoryCtrl,
                                        decoration: InputDecoration(
                                          labelText: 'الفئة',
                                          hintText: 'أدوية',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Manufacturer
                                _buildManufacturerAutocomplete(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: isKeyboardOpen
          ? null
          : Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BaloraColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (!widget.isSingleItem && _continuousMode) ...[
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: BaloraColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSaving ? null : () => _submit(stayInContinuous: true),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text(
                            'حفظ ومسح التالي',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: BaloraColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSaving ? null : () => _submit(stayInContinuous: false),
                          child: const Text(
                            'حفظ وإنهاء',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BaloraColors.primary),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: BaloraColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSaving ? null : () => _submit(stayInContinuous: false),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(
                                  widget.isSingleItem
                                      ? Icons.check_circle_outline
                                      : Icons.cloud_upload_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            widget.isSingleItem ? 'حفظ الصنف' : 'حفظ كمسودة للمراجعة',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String number,
    required String title,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BaloraColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BaloraColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: BaloraColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTradeNameAutocomplete() {
    return RawAutocomplete<DrugSuggestion>(
      textEditingController: _nameArCtrl,
      focusNode: _nameFocusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<DrugSuggestion>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchByName(textEditingValue.text.trim());
      },
      displayStringForOption: (DrugSuggestion option) => option.name,
      onSelected: (DrugSuggestion selection) {
        _populateFromDrugSuggestion(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الاسم التجاري (المادة) *',
            hintText: 'اكتب اسم المادة للبحث في 19,300 دواء...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
          onFieldSubmitted: (val) {
            onFieldSubmitted();
            final service = ref.read(drugSuggestionServiceProvider);
            final match = service.lookupByName(val);
            if (match != null) {
              _populateFromDrugSuggestion(match);
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(240.0, 520.0),
                maxHeight: 220,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final drug = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(drug),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.medication_outlined,
                              color: BaloraColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    drug.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  if (drug.scientificName != null || drug.manufacturer != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if (drug.scientificName != null) drug.scientificName,
                                        if (drug.manufacturer != null) drug.manufacturer,
                                      ].join(' • '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: BaloraColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScientificNameAutocomplete() {
    return RawAutocomplete<String>(
      textEditingController: _scientificNameCtrl,
      focusNode: _scientificNameFocusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchScientificNames(textEditingValue.text.trim());
      },
      onSelected: (String selection) {
        setState(() => _scientificNameCtrl.text = selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الاسم العلمي (المادة الفعالة)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(240.0, 520.0),
                maxHeight: 200,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sci = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(sci),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          sci,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManufacturerAutocomplete() {
    return RawAutocomplete<String>(
      textEditingController: _manufacturerCtrl,
      focusNode: _manufacturerFocusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }
        final service = ref.read(drugSuggestionServiceProvider);
        return service.searchCompanies(textEditingValue.text.trim());
      },
      onSelected: (String selection) {
        setState(() => _manufacturerCtrl.text = selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الشركة المصنعة / المورد',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(240.0, 520.0),
                maxHeight: 200,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comp = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(comp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          comp,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
