import '../models/tax_calculation.dart';
import '../models/tax_return.dart';
import 'api_service.dart';

class TaxService {
  final ApiService _apiService = ApiService();

  static Map<String, dynamic> buildSubmissionPayload({
    required double totalIncome,
    double deductions = 0.0,
    String filingType = 'ORIGINAL',
    String? additionalInfo,
  }) {
    return {
      'totalIncome': totalIncome,
      'deductions': deductions,
      'filingType': filingType,
      if (additionalInfo != null && additionalInfo.isNotEmpty)
        'additionalInfo': additionalInfo,
    };
  }

  Future<TaxReturn> createTaxReturn(String assessmentYear) async {
    try {
      final response = await _apiService.post('/tax-returns/create', {
        'assessmentYear': assessmentYear,
      });
      return TaxReturn.fromJson(response);
    } on ApiException catch (e) {
      if (e.statusCode != 409) rethrow;
      // A return already exists for this year - reuse it instead of failing.
      final existingReturns = await getUserReturns();
      for (final taxReturn in existingReturns) {
        if (taxReturn.assessmentYear == assessmentYear) {
          return taxReturn;
        }
      }
      rethrow;
    }
  }

  Future<TaxReturn> updateTaxReturn(
      int returnId, Map<String, dynamic> payload) async {
    final response = await _apiService.put('/tax-returns/$returnId', payload);
    return TaxReturn.fromJson(response);
  }

  Future<TaxReturn> updateTaxReturnWithValues(
    int returnId, {
    required double totalIncome,
    double deductions = 0.0,
    String filingType = 'ORIGINAL',
    String? additionalInfo,
  }) async {
    final response = await _apiService.put(
      '/tax-returns/$returnId',
      buildSubmissionPayload(
        totalIncome: totalIncome,
        deductions: deductions,
        filingType: filingType,
        additionalInfo: additionalInfo,
      ),
    );
    return TaxReturn.fromJson(response);
  }

  Future<TaxCalculationResponse> calculateTax(
      int returnId, TaxCalculationRequest request) async {
    final response = await _apiService.post('/tax-returns/calculate', {
      ...request.toJson(),
      'returnId': returnId,
    });
    return TaxCalculationResponse.fromJson(response);
  }

  Future<TaxReturn> submitTaxReturn(int returnId) async {
    final response =
        await _apiService.post('/tax-returns/$returnId/submit', {});
    return TaxReturn.fromJson(response);
  }

  static List<TaxReturn> parseTaxReturnListResponse(dynamic response) {
    final List<dynamic> rawReturns;

    if (response is Map<String, dynamic>) {
      rawReturns = (response['content'] as List?) ?? const [];
    } else if (response is List) {
      rawReturns = response;
    } else {
      rawReturns = const [];
    }

    return rawReturns
        .whereType<Map<String, dynamic>>()
        .map((json) => TaxReturn.fromJson(json))
        .toList();
  }

  Future<List<TaxReturn>> getUserReturns() async {
    final response = await _apiService.get('/tax-returns/my-returns');
    return parseTaxReturnListResponse(response);
  }

  Future<List<TaxReturn>> getUserReturnsByUserId(int userId) async {
    final returns = await getUserReturns();
    return returns.where((returnItem) => returnItem.userId == userId).toList();
  }

  Future<TaxReturn> getReturnById(int returnId) async {
    final response = await _apiService.get('/tax-returns/$returnId');
    return TaxReturn.fromJson(response);
  }

  Future<TaxReturn> getReturnByFilingId(String filingId) async {
    final response = await _apiService.get('/tax-returns/filing-id/$filingId');
    return TaxReturn.fromJson(response);
  }

  Future<void> deleteReturn(int returnId) async {
    await _apiService.delete('/tax-returns/$returnId');
  }
}
