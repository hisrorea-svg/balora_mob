import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/result/result.dart';
import '../../../drafts/presentation/widgets/fast_expiry_picker_dialog.dart';
import '../../../scanner/domain/product.dart';
import '../../../scanner/domain/product_repository.dart';
import '../../../scanner/presentation/widgets/barcode_scanner_dialog.dart';
import '../../data/drug_suggestion_service.dart';
import '../../domain/models/drug_suggestion.dart';
import '../product_form_controller.dart';
import '../product_form_state.dart';

/// Modern, unified Product Card screen for Adding a New Product or Editing an Existing Product.
///
/// Fully aligned with Balora's modern UI design system:
/// - Fast autocomplete from 19,300 drug suggestions database
/// - Dual barcodes (Package Barcode + Strip Barcode)
/// - Automatic IQD unit price/cost calculation based on strips per box
/// - Instant 1-tap select for default '1' values without backspacing
/// - Safe keyboard inset layout without bottom bar overlap
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  final String? initialBarcode;

  const ProductFormScreen({super.key, this.product, this.initialBarcode});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Barcodes
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _stripBarcodeCtrl;

  // Names & Details
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _scientificNameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _dosageFormCtrl;
  late final TextEditingController _manufacturerCtrl;

  // Pricing & Packaging
  late final TextEditingController _costPriceBoxCtrl;
  late final TextEditingController _sellPriceBoxCtrl;
  late final TextEditingController _stripsPerBoxCtrl;
  late final TextEditingController _costPriceUnitCtrl;
  late final TextEditingController _sellPriceUnitCtrl;

  // Stock & Location & Expiry
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _storageLocationCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _batchNumberCtrl;
  final TextEditingController _expiryCtrl = TextEditingController();

  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _stripsFocusNode = FocusNode();
  final FocusNode _expiryFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _scientificNameFocusNode = FocusNode();
  final FocusNode _manufacturerFocusNode = FocusNode();

  DateTime? _expiryDate;
  bool _isCheckingBarcode = false;
  bool _isDivisible = true;
  String _quantityUnit = 'box'; // 'box' or 'strip'
  bool _isRecalculating = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _isDivisible = p == null ? true : (p.countInBox > 1);

    _barcodeCtrl = TextEditingController(
      text: p?.barcode ?? widget.initialBarcode ?? '',
    );
    _stripBarcodeCtrl = TextEditingController(text: p?.stripBarcode ?? '');

    _nameCtrl = TextEditingController(text: p?.nameAr ?? p?.name ?? '');
    _nameEnCtrl = TextEditingController(text: p?.nameEn ?? '');
    _scientificNameCtrl = TextEditingController(text: p?.scientificName ?? '');
    _categoryCtrl = TextEditingController(
      text: (p?.category.isNotEmpty ?? false) ? p!.category : 'أدوية',
    );
    _dosageFormCtrl = TextEditingController(text: p?.description ?? '');
    _manufacturerCtrl = TextEditingController(text: p?.manufacturer ?? '');

    _costPriceBoxCtrl = TextEditingController(
      text: (p != null && p.costPrice > 0)
          ? p.costPrice.toStringAsFixed(0)
          : '',
    );
    _sellPriceBoxCtrl = TextEditingController(
      text: (p != null && p.price > 0) ? p.price.toStringAsFixed(0) : '',
    );
    _stripsPerBoxCtrl = TextEditingController(
      text: (p != null && p.countInBox > 0) ? p.countInBox.toString() : '1',
    );
    _costPriceUnitCtrl = TextEditingController(
      text: (p != null && p.costPriceUnit != null && p.costPriceUnit! > 0)
          ? p.costPriceUnit!.toStringAsFixed(0)
          : '',
    );
    _sellPriceUnitCtrl = TextEditingController(
      text: (p != null && p.unitPrice > 0)
          ? p.unitPrice.toStringAsFixed(0)
          : '',
    );

    _quantityCtrl = TextEditingController(
      text: (p != null) ? p.quantity.toString() : '0',
    );
    _storageLocationCtrl = TextEditingController(
      text: p?.storageLocation ?? '',
    );
    _descriptionCtrl = TextEditingController();
    _batchNumberCtrl = TextEditingController(text: p?.batchNumber ?? '');
    _expiryDate = p?.expiryDate;
    if (_expiryDate != null) {
      _expiryCtrl.text = formatPharmaExpiry(_expiryDate!);
    }

    _expiryFocusNode.addListener(() {
      if (!_expiryFocusNode.hasFocus && _expiryCtrl.text.isNotEmpty) {
        final parsed = parsePharmaExpiry(_expiryCtrl.text);
        if (parsed != null) {
          _expiryDate = parsed;
          _expiryCtrl.text = formatPharmaExpiry(parsed);
        }
      }
    });

    // Auto-select text on focus so user can type any digit immediately
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drugSuggestionServiceProvider).loadDrugs();
      if (!_isEdit &&
          widget.initialBarcode != null &&
          widget.initialBarcode!.isNotEmpty) {
        _onBarcodeLookup(widget.initialBarcode!);
      }
    });
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _stripsFocusNode.dispose();
    _expiryFocusNode.dispose();
    _nameFocusNode.dispose();
    _scientificNameFocusNode.dispose();
    _manufacturerFocusNode.dispose();
    _barcodeCtrl.dispose();
    _stripBarcodeCtrl.dispose();
    _nameCtrl.dispose();
    _nameEnCtrl.dispose();
    _scientificNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dosageFormCtrl.dispose();
    _manufacturerCtrl.dispose();
    _costPriceBoxCtrl.dispose();
    _sellPriceBoxCtrl.dispose();
    _stripsPerBoxCtrl.dispose();
    _costPriceUnitCtrl.dispose();
    _sellPriceUnitCtrl.dispose();
    _quantityCtrl.dispose();
    _storageLocationCtrl.dispose();
    _descriptionCtrl.dispose();
    _batchNumberCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
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

  String _formatPrice(double val) {
    if (val <= 0) return '';
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  void _onBoxSellChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final boxSell = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips > 0) {
      final unitSell = boxSell / strips;
      _sellPriceUnitCtrl.text = _formatPrice(unitSell);
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
      final boxSell = unitSell * strips;
      _sellPriceBoxCtrl.text = _formatPrice(boxSell);
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onBoxCostChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final boxCost = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips > 0) {
      final unitCost = boxCost / strips;
      _costPriceUnitCtrl.text = _formatPrice(unitCost);
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onUnitCostChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final unitCost = double.tryParse(val) ?? 0.0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips > 0) {
      final boxCost = unitCost * strips;
      _costPriceBoxCtrl.text = _formatPrice(boxCost);
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _onStripsChanged(String val) {
    if (_isRecalculating) return;
    _isRecalculating = true;
    final strips = int.tryParse(val) ?? 1;
    if (strips > 0) {
      final boxSell = double.tryParse(_sellPriceBoxCtrl.text) ?? 0.0;
      final boxCost = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;

      if (boxSell > 0) {
        final unitSell = boxSell / strips;
        _sellPriceUnitCtrl.text = _formatPrice(unitSell);
      } else {
        final unitSell = double.tryParse(_sellPriceUnitCtrl.text) ?? 0.0;
        if (unitSell > 0) {
          final bSell = unitSell * strips;
          _sellPriceBoxCtrl.text = _formatPrice(bSell);
        }
      }

      if (boxCost > 0) {
        final unitCost = boxCost / strips;
        _costPriceUnitCtrl.text = _formatPrice(unitCost);
      } else {
        final unitCost = double.tryParse(_costPriceUnitCtrl.text) ?? 0.0;
        if (unitCost > 0) {
          final bCost = unitCost * strips;
          _costPriceBoxCtrl.text = _formatPrice(bCost);
        }
      }
    }
    _isRecalculating = false;
    setState(() {});
  }

  void _recalculateUnitPrices() {
    _onStripsChanged(_stripsPerBoxCtrl.text);
  }

  void _onQuantityUnitChanged(String? newUnit) {
    if (newUnit == null || newUnit == _quantityUnit) return;
    final currentQty = int.tryParse(_quantityCtrl.text) ?? 0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;

    setState(() {
      final oldUnit = _quantityUnit;
      _quantityUnit = newUnit;
      if (currentQty > 0 && strips > 0) {
        if (oldUnit == 'box' && newUnit == 'unit') {
          _quantityCtrl.text = (currentQty * strips).toString();
        } else if (oldUnit == 'unit' && newUnit == 'box') {
          _quantityCtrl.text = (currentQty ~/ strips).toString();
        }
      }
    });
  }

  void _toggleQuantityUnit() {
    _onQuantityUnitChanged(_quantityUnit == 'box' ? 'unit' : 'box');
  }

  String _getQuantityEquivalenceText() {
    final qty = int.tryParse(_quantityCtrl.text) ?? 0;
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (qty <= 0 || strips <= 1 || !_isDivisible) return '';

    if (_quantityUnit == 'box') {
      final totalUnits = qty * strips;
      return '$qty علبة = $totalUnits وحدة (العلبة = $strips وحدة)';
    } else {
      final wholeBoxes = qty ~/ strips;
      final remUnits = qty % strips;
      if (remUnits == 0) {
        return '$qty وحدة = $wholeBoxes علبة';
      } else {
        return '$qty وحدة = $wholeBoxes علبة و $remUnits وحدة';
      }
    }
  }

  String _getPriceConversionSummaryText() {
    if (!_isDivisible) return '';
    final strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    if (strips <= 1) return '';

    final sellBox = double.tryParse(_sellPriceBoxCtrl.text) ?? 0.0;
    final sellUnit = double.tryParse(_sellPriceUnitCtrl.text) ?? 0.0;
    final costBox = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
    final costUnit = double.tryParse(_costPriceUnitCtrl.text) ?? 0.0;

    final parts = <String>[];
    if (sellBox > 0 || sellUnit > 0) {
      parts.add(
        'بيع: ${_formatPrice(sellBox)} د.ع (علبة) ⇄ ${_formatPrice(sellUnit)} د.ع (وحدة)',
      );
    }
    if (costBox > 0 || costUnit > 0) {
      parts.add(
        'شراء: ${_formatPrice(costBox)} د.ع (علبة) ⇄ ${_formatPrice(costUnit)} د.ع (وحدة)',
      );
    }
    return parts.join('  •  ');
  }

  Future<void> _onBarcodeLookup(String barcode) async {
    final clean = barcode.trim();
    if (clean.isEmpty) return;

    setState(() => _isCheckingBarcode = true);

    try {
      // 1. Check local pharmacy inventory
      final productRepo = ref.read(productRepositoryProvider);
      final productResult = await productRepo.getProductByBarcode(clean);
      if (productResult case Success(:final data)) {
        if (mounted) {
          _populateFromProduct(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: BaloraColors.primary,
              content: Text(
                'تم العثور على بيانات (${data.name}) في قاعدة بيانات الصيدلية',
              ),
            ),
          );
        }
        return;
      }

      // 2. Check 19,300 drug suggestions database
      final drugService = ref.read(drugSuggestionServiceProvider);
      final suggestion = drugService.lookupByBarcode(clean);
      if (suggestion != null && mounted) {
        _populateFromDrugSuggestion(suggestion);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: BaloraColors.success,
            content: Text(
              'تم التعرف على (${suggestion.name}) من المرجع الدوائي!',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingBarcode = false);
    }
  }

  void _populateFromDrugSuggestion(DrugSuggestion drug) {
    setState(() {
      _nameCtrl.text = drug.name;
      if (drug.barcode != null &&
          drug.barcode!.trim().isNotEmpty &&
          _barcodeCtrl.text.trim().isEmpty) {
        _barcodeCtrl.text = drug.barcode!.trim();
      }
      if (drug.scientificName != null && drug.scientificName!.isNotEmpty) {
        _scientificNameCtrl.text = drug.scientificName!;
      }
      if (drug.category != null && drug.category!.isNotEmpty) {
        _categoryCtrl.text = drug.category!;
      }
      if (drug.manufacturer != null && drug.manufacturer!.isNotEmpty) {
        _manufacturerCtrl.text = drug.manufacturer!;
      }
      if (drug.dosageForm != null && drug.dosageForm!.isNotEmpty) {
        _dosageFormCtrl.text = drug.dosageForm!;
      }
      final strips = (drug.stripsPerBox != null && drug.stripsPerBox! > 0)
          ? drug.stripsPerBox!
          : 1;
      _stripsPerBoxCtrl.text = strips.toString();
      _isDivisible = strips > 1;

      if (drug.suggestedCost != null && drug.suggestedCost! > 0) {
        _costPriceBoxCtrl.text = drug.suggestedCost!.toStringAsFixed(0);
        _costPriceUnitCtrl.text = _formatPrice(drug.suggestedCost! / strips);
      }
      if (drug.suggestedPrice != null && drug.suggestedPrice! > 0) {
        _sellPriceBoxCtrl.text = drug.suggestedPrice!.toStringAsFixed(0);
        _sellPriceUnitCtrl.text = _formatPrice(drug.suggestedPrice! / strips);
      }
      _recalculateUnitPrices();
    });
  }

  void _populateFromProduct(Product product) {
    setState(() {
      _nameCtrl.text = product.nameAr ?? product.name;
      if (_barcodeCtrl.text.trim().isEmpty && product.barcode.isNotEmpty) {
        _barcodeCtrl.text = product.barcode;
      }
      if (product.nameEn != null && product.nameEn!.isNotEmpty) {
        _nameEnCtrl.text = product.nameEn!;
      }
      if (product.scientificName != null &&
          product.scientificName!.isNotEmpty) {
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
      _isDivisible = strips > 1;

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
      if (product.storageLocation != null &&
          product.storageLocation!.isNotEmpty) {
        _storageLocationCtrl.text = product.storageLocation!;
      }
      if (product.batchNumber != null && product.batchNumber!.isNotEmpty) {
        _batchNumberCtrl.text = product.batchNumber!;
      }
      if (product.expiryDate != null) {
        _expiryDate = product.expiryDate;
        _expiryCtrl.text = formatPharmaExpiry(product.expiryDate!);
      }
      _recalculateUnitPrices();
    });
  }

  void _resetForm() {
    _barcodeCtrl.clear();
    _stripBarcodeCtrl.clear();
    _nameCtrl.clear();
    _nameEnCtrl.clear();
    _scientificNameCtrl.clear();
    _categoryCtrl.text = 'أدوية';
    _dosageFormCtrl.clear();
    _manufacturerCtrl.clear();
    _costPriceBoxCtrl.clear();
    _sellPriceBoxCtrl.clear();
    _stripsPerBoxCtrl.text = '1';
    _costPriceUnitCtrl.clear();
    _sellPriceUnitCtrl.clear();
    _quantityCtrl.text = '0';
    _storageLocationCtrl.clear();
    _descriptionCtrl.clear();
    _batchNumberCtrl.clear();
    _expiryCtrl.clear();
    _expiryDate = null;
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تصحيح الحقول المطلوبة باللون الأحمر'),
          backgroundColor: BaloraColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(_sellPriceBoxCtrl.text) ?? 0.0;
    final costPrice = double.tryParse(_costPriceBoxCtrl.text) ?? 0.0;
    int strips = 1;
    if (_isDivisible) {
      strips = int.tryParse(_stripsPerBoxCtrl.text) ?? 1;
    }
    final unitPrice = _isDivisible
        ? (double.tryParse(_sellPriceUnitCtrl.text) ??
            (strips > 0 ? (price / strips) : 0.0))
        : price;
    final unitCost = _isDivisible
        ? (double.tryParse(_costPriceUnitCtrl.text) ??
            (strips > 0 ? (costPrice / strips) : 0.0))
        : costPrice;

    final rawQty = int.tryParse(_quantityCtrl.text) ?? 0;
    final quantity = (_quantityUnit == 'unit' && strips > 1)
        ? (rawQty / strips).ceil()
        : rawQty;

    final parsedExp = parsePharmaExpiry(_expiryCtrl.text);
    final effectiveExpiry = parsedExp ?? _expiryDate;

    final product = Product(
      barcode: _barcodeCtrl.text.trim(),
      stripBarcode: _stripBarcodeCtrl.text.trim().isEmpty
          ? null
          : _stripBarcodeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      nameAr: _nameCtrl.text.trim(),
      nameEn: _nameEnCtrl.text.trim().isEmpty ? null : _nameEnCtrl.text.trim(),
      scientificName: _scientificNameCtrl.text.trim().isEmpty
          ? null
          : _scientificNameCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'أدوية'
          : _categoryCtrl.text.trim(),
      manufacturer: _manufacturerCtrl.text.trim().isEmpty
          ? null
          : _manufacturerCtrl.text.trim(),
      price: price,
      costPrice: costPrice,
      countInBox: strips,
      unitPrice: unitPrice,
      costPriceUnit: unitCost,
      quantity: quantity,
      batchNumber: _batchNumberCtrl.text.trim().isEmpty
          ? null
          : _batchNumberCtrl.text.trim(),
      expiryDate: effectiveExpiry,
      storageLocation: _storageLocationCtrl.text.trim().isEmpty
          ? null
          : _storageLocationCtrl.text.trim(),
      description: _dosageFormCtrl.text.trim().isEmpty
          ? null
          : _dosageFormCtrl.text.trim(),
    );

    ref
        .read(productFormControllerProvider.notifier)
        .submitProduct(isEdit: _isEdit, product: product);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productFormControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () {
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
                      _isEdit
                          ? 'تم تحديث بيانات (${_nameCtrl.text}) بنجاح!'
                          : 'تم حفظ الصنف (${_nameCtrl.text}) في النظام!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
          Navigator.of(context).pop();
        },
        error: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: BaloraColors.error,
              content: Text('خطأ: $msg'),
            ),
          );
        },
        orElse: () {},
      );
    });

    final state = ref.watch(productFormControllerProvider);
    final isSaving = state.maybeWhen(saving: () => true, orElse: () => false);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: BaloraColors.surface,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'تعديل بيانات الصنف' : 'بطاقة صنف جديد',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: BaloraColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isSaving)
            IconButton(
              tooltip: _isEdit ? 'حفظ التعديلات' : 'حفظ الصنف',
              icon: const Icon(Icons.check_rounded),
              onPressed: _submit,
            ),
          if (!_isEdit)
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  isKeyboardOpen ? 24 : 100,
                ),
                children: [
                  // 1. Item & Packaging Section (المادة والتعبئة)
                  _buildSectionCard(
                    stepNumber: '1',
                    title: 'المادة والتعبئة',
                    badgeColor: BaloraColors.primary,
                    icon: Icons.medication_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _barcodeCtrl,
                          enabled: !_isEdit,
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                if (!_isEdit)
                                  IconButton(
                                    tooltip: 'مسح الباركود بالكاميرا',
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: BaloraColors.primary,
                                    ),
                                    onPressed: () async {
                                      final code =
                                          await showBarcodeScannerDialog(
                                            context,
                                          );
                                      if (code != null && code.isNotEmpty) {
                                        _barcodeCtrl.text = code;
                                        _onBarcodeLookup(code);
                                      }
                                    },
                                  ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          onFieldSubmitted: _onBarcodeLookup,
                        ),
                        const SizedBox(height: 12),
                        _buildTradeNameAutocomplete(),
                        const SizedBox(height: 14),

                        // Packaging Mode Toggle (Segmented style matching Balora Desktop)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isDivisible = false;
                                    _stripsPerBoxCtrl.text = '1';
                                    _costPriceUnitCtrl.text =
                                        _costPriceBoxCtrl.text;
                                    _sellPriceUnitCtrl.text =
                                        _sellPriceBoxCtrl.text;
                                    _quantityUnit = 'box';
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isDivisible
                                        ? BaloraColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !_isDivisible
                                          ? BaloraColors.primary
                                          : BaloraColors.borderSubtle,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'علبة فقط',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: !_isDivisible
                                          ? Colors.white
                                          : BaloraColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isDivisible = true;
                                    _recalculateUnitPrices();
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isDivisible
                                        ? BaloraColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _isDivisible
                                          ? BaloraColors.primary
                                          : BaloraColors.borderSubtle,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'تجزئة (علبة + وحدات)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _isDivisible
                                          ? Colors.white
                                          : BaloraColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // If divisible: Units per box & Unit Barcode
                        if (_isDivisible) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _stripsPerBoxCtrl,
                            focusNode: _stripsFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'عدد الوحدات داخل العلبة *',
                              hintText: '1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (!_isDivisible) return null;
                              final val = int.tryParse(v ?? '');
                              return (val == null || val < 1)
                                  ? '1 على الأقل'
                                  : null;
                            },
                            onChanged: _onStripsChanged,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _stripBarcodeCtrl,
                            decoration: InputDecoration(
                              labelText: 'باركود الوحدة (اختياري)',
                              hintText: 'امسح أو اكتب باركود الوحدة إن وُجد',
                              helperText:
                                  'اختياري — يُستخدم لبيع الوحدة المفردة بالباركود',
                              helperStyle: const TextStyle(
                                fontSize: 11,
                                color: BaloraColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                tooltip: 'مسح باركود الوحدة بالكاميرا',
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: BaloraColors.textSecondary,
                                ),
                                onPressed: () async {
                                  final code = await showBarcodeScannerDialog(
                                    context,
                                  );
                                  if (code != null && code.isNotEmpty) {
                                    _stripBarcodeCtrl.text = code;
                                  }
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Stock & Cost Section (المخزون والشراء)
                  _buildSectionCard(
                    stepNumber: '2',
                    title: 'المخزون والشراء',
                    badgeColor: const Color(0xFF059669),
                    icon: Icons.inventory_2_rounded,
                    child: Column(
                      children: [
                        // Row 1: Stock Quantity & Location
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityCtrl,
                                focusNode: _quantityFocusNode,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _quantityUnit == 'unit'
                                      ? 'الكمية الافتتاحية (وحدة)'
                                      : 'الكمية الافتتاحية (علبة)',
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _storageLocationCtrl,
                                decoration: InputDecoration(
                                  labelText: 'مكان الرف / التخزين',
                                  hintText: 'A1, رف 3...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Row 2: Purchase Cost (Box & Unit)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _costPriceBoxCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'سعر شراء العلبة *',
                                  suffixText: 'د.ع',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'مطلوب'
                                    : null,
                                onChanged: _onBoxCostChanged,
                              ),
                            ),
                            if (_isDivisible) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _costPriceUnitCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'تكلفة شراء الوحدة',
                                    suffixText: 'د.ع',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: _onUnitCostChanged,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Live Stock Equivalence Badge (if divisible)
                        if (_isDivisible &&
                            _getQuantityEquivalenceText().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF059669,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF059669,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sync_alt_rounded,
                                  size: 16,
                                  color: Color(0xFF059669),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'المعادلة: ${_getQuantityEquivalenceText()}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _toggleQuantityUnit,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF059669,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.autorenew_rounded,
                                          size: 13,
                                          color: Color(0xFF059669),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _quantityUnit == 'unit'
                                              ? 'إدخال بالعلبة'
                                              : 'إدخال بالوحدة',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Pricing & Expiry Section (التسعير والصلاحية)
                  _buildSectionCard(
                    stepNumber: '3',
                    title: 'التسعير والصلاحية',
                    badgeColor: const Color(0xFFD97706),
                    icon: Icons.sell_rounded,
                    child: Column(
                      children: [
                        // Row 1: Sell Prices (Box & Unit)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _sellPriceBoxCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'سعر بيع العلبة *',
                                  suffixText: 'د.ع',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'مطلوب'
                                    : null,
                                onChanged: _onBoxSellChanged,
                              ),
                            ),
                            if (_isDivisible) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _sellPriceUnitCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'سعر بيع الوحدة *',
                                    suffixText: 'د.ع',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: _onUnitSellChanged,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Row 2: Expiry Date & Batch Number
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryCtrl,
                                focusNode: _expiryFocusNode,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'تاريخ الصلاحية (MM/YYYY) *',
                                  hintText: 'مثال: 128 أو 1227',
                                  suffixIcon: IconButton(
                                    tooltip: 'اختيار التاريخ السريع',
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Color(0xFFD97706),
                                    ),
                                    onPressed: _openFastExpiryPicker,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (val) {
                                  final clean = val.trim().replaceAll(' ', '').replaceAll('-', '').replaceAll('.', '');
                                  if (clean.length == 3 && !clean.contains('/')) {
                                    final m = int.tryParse(clean.substring(0, 1));
                                    final y = int.tryParse(clean.substring(1, 3));
                                    if (m != null &&
                                        m >= 1 &&
                                        m <= 9 &&
                                        y != null &&
                                        y >= 24 &&
                                        y <= 35) {
                                      final formatted = '0$m/20$y';
                                      _expiryCtrl.text = formatted;
                                      _expiryCtrl.selection =
                                          TextSelection.collapsed(
                                        offset: formatted.length,
                                      );
                                      _expiryDate =
                                          parsePharmaExpiry(formatted);
                                    }
                                  } else if (clean.length == 4 &&
                                      !clean.contains('/')) {
                                    final m = int.tryParse(clean.substring(0, 2));
                                    final y = int.tryParse(clean.substring(2, 4));
                                    if (m != null &&
                                        m >= 1 &&
                                        m <= 12 &&
                                        y != null &&
                                        y >= 24 &&
                                        y <= 35) {
                                      final formatted =
                                          '${m.toString().padLeft(2, '0')}/20$y';
                                      _expiryCtrl.text = formatted;
                                      _expiryCtrl.selection =
                                          TextSelection.collapsed(
                                        offset: formatted.length,
                                      );
                                      _expiryDate =
                                          parsePharmaExpiry(formatted);
                                    }
                                  } else if (clean.length == 6 &&
                                      !clean.contains('/')) {
                                    final m = int.tryParse(clean.substring(2, 4));
                                    final y = int.tryParse(clean.substring(4, 6));
                                    if (m != null &&
                                        m >= 1 &&
                                        m <= 12 &&
                                        y != null &&
                                        y >= 24 &&
                                        y <= 35) {
                                      final formatted =
                                          '${m.toString().padLeft(2, '0')}/20$y';
                                      _expiryCtrl.text = formatted;
                                      _expiryCtrl.selection =
                                          TextSelection.collapsed(
                                        offset: formatted.length,
                                      );
                                      _expiryDate =
                                          parsePharmaExpiry(formatted);
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _batchNumberCtrl,
                                decoration: InputDecoration(
                                  labelText: 'رقم الوجبة / التشغيلة',
                                  hintText: 'e.g. B2409',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Conversion Summary Badge
                        if (_getPriceConversionSummaryText().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD97706,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFFD97706,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getPriceConversionSummaryText(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Additional Info & Labeling Section (بيانات إضافية والملصق)
                  _buildSectionCard(
                    stepNumber: '4',
                    title: 'بيانات إضافية والملصق (اختياري)',
                    badgeColor: const Color(0xFF475569),
                    icon: Icons.info_outline_rounded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameEnCtrl,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الإنكليزي (للملصقات)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _dosageFormCtrl,
                                decoration: InputDecoration(
                                  labelText: 'الشكل الصيدلاني',
                                  hintText: 'حبوب، شراب، قطرات...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildScientificNameAutocomplete(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildManufacturerAutocomplete()),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _categoryCtrl,
                                decoration: InputDecoration(
                                  labelText: 'التصنيف',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
              padding: const EdgeInsets.all(16),
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
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: BaloraColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSaving ? null : _submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      _isEdit ? 'حفظ التعديلات' : 'حفظ الصنف في النظام',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? stepNumber,
    Color? badgeColor,
    required IconData icon,
    Widget? action,
    required Widget child,
  }) {
    final effectiveColor = badgeColor ?? BaloraColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: BaloraColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaloraColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (stepNumber != null) ...[
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: effectiveColor),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: effectiveColor,
                  ),
                ),
              ),
              ?action,
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
      textEditingController: _nameCtrl,
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
            labelText: 'الاسم التجاري (العربي / العام) *',
            hintText: 'اكتب حرفين للبحث في 19,300 دواء...',
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
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(
                  240.0,
                  520.0,
                ),
                maxHeight: 220,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final drug = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(drug),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                                  if (drug.scientificName != null ||
                                      drug.manufacturer != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if (drug.scientificName != null)
                                          drug.scientificName,
                                        if (drug.manufacturer != null)
                                          drug.manufacturer,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(
                  240.0,
                  520.0,
                ),
                maxHeight: 200,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sci = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(sci),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          sci,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(
                  240.0,
                  520.0,
                ),
                maxHeight: 200,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comp = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(comp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          comp,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
