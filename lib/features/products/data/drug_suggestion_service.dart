import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/drug_suggestion.dart';

final drugSuggestionServiceProvider = Provider<DrugSuggestionService>((ref) {
  return DrugSuggestionService();
});

class DrugSuggestionService {
  List<DrugSuggestion> _suggestions = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadDrugs() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/drug_assest/drugs.json',
      );
      _suggestions = await compute(_parseDrugs, jsonString);
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading drug suggestions: $e');
    } finally {
      _isLoading = false;
    }
  }

  static List<DrugSuggestion> _parseDrugs(String jsonString) {
    final parsed = jsonDecode(jsonString) as List<dynamic>;
    return parsed
        .map((e) => DrugSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<DrugSuggestion> searchByName(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _suggestions
        .where((drug) => drug.name.toLowerCase().contains(lowerQuery))
        .take(10)
        .toList();
  }

  List<String> searchScientificNames(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final names = <String>{};
    for (final drug in _suggestions) {
      if (drug.scientificName != null &&
          drug.scientificName!.isNotEmpty &&
          drug.scientificName!.toLowerCase().contains(lowerQuery)) {
        names.add(drug.scientificName!);
      }
      if (names.length >= 10) break;
    }
    return names.toList();
  }

  List<String> searchCompanies(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final companies = <String>{};
    for (final drug in _suggestions) {
      if (drug.manufacturer != null &&
          drug.manufacturer!.isNotEmpty &&
          drug.manufacturer!.toLowerCase().contains(lowerQuery)) {
        companies.add(drug.manufacturer!);
      }
      if (companies.length >= 10) break;
    }
    return companies.toList();
  }
}
