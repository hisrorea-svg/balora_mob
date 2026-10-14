class DrugSuggestion {
  final String name;
  final String? scientificName;
  final String? manufacturer;
  final String? category;

  const DrugSuggestion({
    required this.name,
    this.scientificName,
    this.manufacturer,
    this.category,
  });

  factory DrugSuggestion.fromJson(Map<String, dynamic> json) {
    return DrugSuggestion(
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String?,
      manufacturer: json['manufacturer'] as String?,
      category: json['category'] as String?,
    );
  }
}
