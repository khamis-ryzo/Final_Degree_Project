import 'package:flutter/material.dart';
// Removed dependency on the external provider package to avoid missing URI error.
// import 'package:provider/provider.dart';
import '../providers/tax_provider.dart';
import '../widgets/tax_card.dart';

class ReturnsHistoryScreen extends StatefulWidget {
  const ReturnsHistoryScreen({super.key});

  @override
  State<ReturnsHistoryScreen> createState() => _ReturnsHistoryScreenState();
}

class _ReturnsHistoryScreenState extends State<ReturnsHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'COMPLETED',
    'SUBMITTED',
    'DRAFT',
    'REJECTED',
  ];
  final TaxProvider _taxProvider = TaxProvider();

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    await _taxProvider.loadReturns();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Returns History'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReturns),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Builder(
              builder: (context) {
                final taxProvider = _taxProvider;

                if (taxProvider.isLoading && taxProvider.returns.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredReturns = _selectedFilter == 'All'
                    ? taxProvider.returns
                    : taxProvider.returns
                          .where((r) => r.status == _selectedFilter)
                          .toList();

                if (filteredReturns.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadReturns,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReturns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return TaxCard(taxReturn: filteredReturns[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
            checkmarkColor: const Color(0xFF2E7D32),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No tax returns found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your filed tax returns will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/file-return');
              },
              icon: const Icon(Icons.add),
              label: const Text('File New Return'),
            ),
          ],
        ),
      ),
    );
  }
}

// Use TaxProvider's properties directly; no extension needed.
