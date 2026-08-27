import 'package:flutter/material.dart';
import '../models/tax_return.dart';
import 'search_result_card.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<TaxReturn> taxReturns;
  final List<Map<String, dynamic>> payments;
  final Function(String, String) onSearch;

  CustomSearchDelegate({
    required this.taxReturns,
    required this.payments,
    required this.onSearch,
  });

  @override
  String get searchFieldLabel => 'Search tax returns, payments...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }

    final results = _searchResults(query);
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SearchResultCard(
            data: result,
            type: result['type'],
            onTap: () {
              _handleResultTap(context, result);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearchSuggestions(context);
    }

    final results = _searchResults(query);
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No suggestions found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length > 5 ? 5 : results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          leading: Icon(
            _getResultIcon(result['type']),
            color: Theme.of(context).primaryColor,
          ),
          title: Text(_getResultTitle(result)),
          subtitle: Text(_getResultSubtitle(result)),
          onTap: () {
            query = _getResultTitle(result);
            showResults(context);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _searchResults(String query) {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    // Search in tax returns
    for (var item in taxReturns) {
      if (item.filingId.toLowerCase().contains(lowerQuery) ||
          item.tinNumber.toLowerCase().contains(lowerQuery) ||
          item.assessmentYear.toLowerCase().contains(lowerQuery)) {
        results.add({
          ...item.toJson(),
          'type': 'tax_return',
        });
      }
    }

    // Search in payments
    for (var item in payments) {
      final paymentReference = item['paymentReference']?.toString() ?? '';
      final controlNumber = item['controlNumber']?.toString() ?? '';
      final transactionId = item['transactionId']?.toString() ?? '';

      if (paymentReference.toLowerCase().contains(lowerQuery) ||
          controlNumber.toLowerCase().contains(lowerQuery) ||
          transactionId.toLowerCase().contains(lowerQuery)) {
        results.add({
          ...item,
          'type': 'payment',
        });
      }
    }

    return results;
  }

  Widget _buildRecentSearchSuggestions(BuildContext context) {
    final recentSearches = [
      'Tax Return 2024',
      'Payment #12345',
      'TIN: 1234567890'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...recentSearches.map((search) => ListTile(
              leading: const Icon(Icons.history, size: 16, color: Colors.grey),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  // Remove from recent searches
                },
              ),
              onTap: () {
                query = search;
                showResults(context);
              },
            )),
      ],
    );
  }

  IconData _getResultIcon(String type) {
    switch (type) {
      case 'tax_return':
        return Icons.assignment;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.search;
    }
  }

  String _getResultTitle(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'tax_return':
        return result['filingId'] ?? 'Tax Return';
      case 'payment':
        return result['paymentReference'] ?? 'Payment';
      default:
        return 'Result';
    }
  }

  String _getResultSubtitle(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'tax_return':
        return '${result['assessmentYear'] ?? ''} • ${result['status'] ?? ''}';
      case 'payment':
        return '${result['paymentMethod'] ?? ''} • ${result['paymentStatus'] ?? ''}';
      default:
        return '';
    }
  }

  void _handleResultTap(BuildContext context, Map<String, dynamic> result) {
    close(context, result['type']);
    onSearch(result['type'], result['id'].toString());
  }
}
