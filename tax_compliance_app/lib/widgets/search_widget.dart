import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/helpers.dart';
import 'advanced_search_widget.dart';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function(Map<String, dynamic>)? onAdvancedSearch;
  final List<String>? suggestions;
  final bool showAdvancedSearch;
  final bool showFilterChips;
  final List<SearchFilterChip>? filterChips;
  final Function(String)? onFilterSelected;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final double? width;
  final EdgeInsets? padding;

  const SearchWidget({
    super.key,
    this.hintText = 'Search...',
    required this.onSearch,
    this.onAdvancedSearch,
    this.suggestions,
    this.showAdvancedSearch = true,
    this.showFilterChips = false,
    this.filterChips,
    this.onFilterSelected,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.width,
    this.padding,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isExpanded = false;
  String? _selectedFilter;
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // Load from shared preferences
    // For demo, using dummy data
    _recentSearches
        .addAll(['Tax Return 2024', 'Payment #12345', 'TIN: 1234567890']);
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }
    widget.onSearch(query);
  }

  void _clearSearch() {
    _controller.clear();
    _handleSearch('');
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search Icon
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                ),

                // Search Input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autoFocus,
                    onChanged: (query) {
                      if (query.isEmpty) {
                        widget.onSearch('');
                      }
                    },
                    onSubmitted: _handleSearch,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                  ),
                ),

                // Clear Button
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSearch,
                    tooltip: 'Clear',
                  ),

                // Advanced Search Button
                if (widget.showAdvancedSearch)
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.filter_list_off : Icons.filter_list,
                      color: _isExpanded
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    tooltip: 'Advanced Search',
                  ),

                // Voice Search Button (Optional)
                IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: () {
                    Helpers.showInfoSnackBar(
                        context, 'Voice search coming soon!');
                  },
                  tooltip: 'Voice Search',
                ),
              ],
            ),
          ),

          // Recent Searches
          if (_focusNode.hasFocus && _recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches.map((search) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = search;
                            _handleSearch(search);
                            _focusNode.unfocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  search,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // Suggestions
          if (_controller.text.isNotEmpty &&
              widget.suggestions != null &&
              widget.suggestions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.suggestions!
                        .where((s) => s
                            .toLowerCase()
                            .contains(_controller.text.toLowerCase()))
                        .take(5)
                        .map((suggestion) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.grey,
                        ),
                        title: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          _controller.text = suggestion;
                          _handleSearch(suggestion);
                          _focusNode.unfocus();
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Filter Chips
          if (widget.showFilterChips && widget.filterChips != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "All" chip
                    _buildFilterChip('All', null),
                    ...widget.filterChips!.map((chip) => _buildFilterChip(
                          chip.label,
                          chip.value,
                        )),
                  ],
                ),
              ),
            ),

          // Advanced Search Panel
          if (_isExpanded)
            AdvancedSearchWidget(
              onApply: (filters) {
                if (widget.onAdvancedSearch != null) {
                  widget.onAdvancedSearch!(filters);
                }
                setState(() {
                  _isExpanded = false;
                });
              },
              onClear: () {
                if (widget.onAdvancedSearch != null) {
                  widget.onAdvancedSearch!({});
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : null;
          });
          if (widget.onFilterSelected != null) {
            widget.onFilterSelected!(_selectedFilter ?? '');
          }
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

// ==================== SEARCH FILTER CHIP MODEL ====================

class SearchFilterChip {
  final String label;
  final String value;

  SearchFilterChip({
    required this.label,
    required this.value,
  });
}
