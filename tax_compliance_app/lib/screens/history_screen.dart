import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tax_provider.dart';
import '../models/tax_return.dart';
import '../services/tra_report_service.dart';
import '../widgets/search_widget.dart';
import '../widgets/search_delegate.dart';
import '../widgets/search_result_card.dart';
import 'return_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};
  String _selectedFilter = '';

  @override
  Widget build(BuildContext context) {
    final taxProvider = Provider.of<TaxProvider>(context);
    final returns = _filteredReturns(taxProvider.returns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  taxReturns: taxProvider.returns,
                  payments: [],
                  onSearch: (type, id) {
                    // Navigate to detail
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Widget
          SearchWidget(
            hintText: 'Search returns by ID, TIN, or year...',
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onAdvancedSearch: (filters) {
              setState(() {
                _filters = filters;
              });
            },
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            showAdvancedSearch: true,
            showFilterChips: true,
            filterChips: [
              SearchFilterChip(label: 'Completed', value: 'COMPLETED'),
              SearchFilterChip(label: 'Submitted', value: 'SUBMITTED'),
              SearchFilterChip(label: 'Draft', value: 'DRAFT'),
              SearchFilterChip(label: 'Rejected', value: 'REJECTED'),
            ],
            suggestions: const [
              '2024/2025',
              '2023/2024',
              'TR-2024-001',
              'TIN: 1234567890'
            ],
          ),

          // Results
          Expanded(
            child: returns.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No results found'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: returns.length,
                    itemBuilder: (context, index) {
                      final item = returns[index];
                      return SearchResultCard(
                        data: {
                          ...item.toJson(),
                          'type': 'tax_return',
                        },
                        type: 'tax_return',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReturnDetailScreen(taxReturn: item),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          tooltip: 'Download PDF',
                          onPressed: () => _downloadPdf(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(TaxReturn returnItem) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (user == null) {
      messenger?.showSnackBar(
        const SnackBar(
            content: Text('User session expired. Please log in again.')),
      );
      return;
    }

    try {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      final taxData = {
        'taxPayable': returnItem.taxPayable,
        'totalLiability': returnItem.totalLiability,
        'totalTax': returnItem.totalLiability,
        'totalIncome': returnItem.totalIncome,
        'taxableIncome': returnItem.taxableIncome,
        'skillsLevy': returnItem.skillsLevy,
        'railwayLevy': returnItem.railwayLevy,
        'cess': returnItem.cessAmount,
        'interest': returnItem.interest,
        'penalty': returnItem.penalty,
        'employmentIncome': returnItem.employmentIncome,
        'businessIncome': returnItem.businessIncome,
        'rentalIncome': returnItem.rentalIncome,
        'totalDeductions': returnItem.totalDeductions,
      };

      final file = await TRAReportService.generateTRAReport(
        returnItem,
        user,
        taxData,
      );

      await TRAReportService.downloadReport(file);
      messenger?.showSnackBar(
        const SnackBar(content: Text('PDF downloaded successfully.')),
      );
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
    }
  }

  List<TaxReturn> _filteredReturns(List<TaxReturn> returns) {
    var filtered = returns;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.filingId.toLowerCase().contains(query) ||
              r.tinNumber.toLowerCase().contains(query) ||
              r.assessmentYear.toLowerCase().contains(query))
          .toList();
    }

    // Status filter
    if (_selectedFilter.isNotEmpty) {
      filtered = filtered.where((r) => r.status == _selectedFilter).toList();
    }

    // Advanced filters
    if (_filters.isNotEmpty) {
      if (_filters.containsKey('status')) {
        filtered =
            filtered.where((r) => r.status == _filters['status']).toList();
      }
      if (_filters.containsKey('filingType')) {
        filtered = filtered
            .where((r) => r.filingType == _filters['filingType'])
            .toList();
      }
      if (_filters.containsKey('assessmentYear')) {
        filtered = filtered
            .where((r) => r.assessmentYear == _filters['assessmentYear'])
            .toList();
      }
      if (_filters.containsKey('amountMin')) {
        filtered = filtered
            .where((r) => r.totalLiability >= _filters['amountMin'])
            .toList();
      }
      if (_filters.containsKey('amountMax')) {
        filtered = filtered
            .where((r) => r.totalLiability <= _filters['amountMax'])
            .toList();
      }
    }

    return filtered;
  }
}
