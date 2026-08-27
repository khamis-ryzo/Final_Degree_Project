class TaxCalculationRequest {
  final double totalIncome;
  final double deductions;
  final int? returnId;

  const TaxCalculationRequest({
    required this.totalIncome,
    required this.deductions,
    this.returnId,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'deductions': deductions,
      'returnId': returnId,
    };
  }
}

class TaxCalculationResponse {
  final double taxableIncome;
  final double taxPayable;
  final double cess;
  final double totalTax;
  final double skillsLevy;
  final double railwayLevy;

  const TaxCalculationResponse({
    required this.taxableIncome,
    required this.taxPayable,
    required this.cess,
    required this.totalTax,
    this.skillsLevy = 0.0,
    this.railwayLevy = 0.0,
  });

  factory TaxCalculationResponse.fromJson(Map<String, dynamic> json) {
    final taxableIncome =
        (json['taxableIncome'] ?? json['taxable_income'] ?? 0).toDouble();
    final taxPayable =
        (json['taxPayable'] ?? json['taxDue'] ?? json['incomeTax'] ?? 0)
            .toDouble();
    final cess =
        (json['cess'] ?? json['healthAndEducationCess'] ?? 0).toDouble();
    final totalTax = (json['totalTax'] ??
            json['totalTaxLiability'] ??
            json['totalLiability'] ??
            taxPayable + cess)
        .toDouble();
    final skillsLevy =
        (json['skillsLevy'] ?? json['skills_levy'] ?? 0).toDouble();
    final railwayLevy =
        (json['railwayLevy'] ?? json['railway_levy'] ?? 0).toDouble();

    return TaxCalculationResponse(
      taxableIncome: taxableIncome,
      taxPayable: taxPayable,
      cess: cess,
      totalTax: totalTax,
      skillsLevy: skillsLevy,
      railwayLevy: railwayLevy,
    );
  }
}
