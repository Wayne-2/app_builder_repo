class DataVariation {
  final String name;
  final String variationCode;
  final double variationAmount;

  DataVariation({
    required this.name,
    required this.variationCode,
    required this.variationAmount,
  });

  factory DataVariation.fromJson(Map<String, dynamic> json) {
    return DataVariation(
      name: json["name"] ?? "",
      variationCode: json["variation_code"] ?? "",
      variationAmount: double.tryParse(json["variation_amount"].toString()) ?? 0.0,
    );
  }
}
