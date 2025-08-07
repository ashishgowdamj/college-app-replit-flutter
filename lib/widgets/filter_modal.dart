import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/college_provider.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _selectedState;
  String? _selectedType;
  RangeValues _feeRange = const RangeValues(0, 500000);
  String? _selectedRanking;
  bool _hasHostel = false;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CollegeProvider>();
      _selectedState = provider.selectedState;
      _selectedType = provider.selectedCourseType;
      _minRating = provider.colleges.isNotEmpty 
          ? provider.colleges.map((c) => c.ratingAsDouble).reduce((a, b) => a < b ? a : b)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // State filter
                  _buildSectionTitle('Location'),
                  _buildStateFilter(),
                  const SizedBox(height: 24),
                  
                  // College type filter
                  _buildSectionTitle('College Type'),
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  
                  // Fee range filter
                  _buildSectionTitle('Fee Range'),
                  _buildFeeRangeFilter(),
                  const SizedBox(height: 24),
                  
                  // Rating filter
                  _buildSectionTitle('Minimum Rating'),
                  _buildRatingFilter(),
                  const SizedBox(height: 24),
                  
                  // Ranking filter
                  _buildSectionTitle('Ranking'),
                  _buildRankingFilter(),
                  const SizedBox(height: 24),
                  
                  // Hostel filter
                  _buildSectionTitle('Facilities'),
                  _buildHostelFilter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStateFilter() {
    final states = [
      'Andhra Pradesh', 'Delhi', 'Gujarat', 'Karnataka', 'Kerala',
      'Maharashtra', 'Tamil Nadu', 'Telangana', 'Uttar Pradesh', 'West Bengal'
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: states.map((state) {
        final isSelected = _selectedState == state;
        return FilterChip(
          label: Text(state),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedState = selected ? state : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTypeFilter() {
    final types = [
      'Government', 'Private', 'IIT', 'Medical', 'Management',
      'Deemed University', 'Central University', 'State University'
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = selected ? type : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeeRangeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _feeRange,
          min: 0,
          max: 500000,
          divisions: 50,
          labels: RangeLabels(
            '₹${(_feeRange.start / 1000).round()}K',
            '₹${(_feeRange.end / 1000).round()}K',
          ),
          onChanged: (values) {
            setState(() {
              _feeRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${(_feeRange.start / 1000).round()}K'),
            Text('₹${(_feeRange.end / 1000).round()}K'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      children: [
        Slider(
          value: _minRating ?? 0,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating?.toStringAsFixed(1) ?? 'Any',
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Any'),
            Text(_minRating?.toStringAsFixed(1) ?? 'Any'),
          ],
        ),
      ],
    );
  }

  Widget _buildRankingFilter() {
    final rankings = ['Top 10', 'Top 25', 'Top 50', 'Top 100'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rankings.map((ranking) {
        final isSelected = _selectedRanking == ranking;
        return FilterChip(
          label: Text(ranking),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedRanking = selected ? ranking : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildHostelFilter() {
    return SwitchListTile(
      title: const Text('Has Hostel'),
      subtitle: const Text('Show only colleges with hostel facilities'),
      value: _hasHostel,
      onChanged: (value) {
        setState(() {
          _hasHostel = value;
        });
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedState = null;
      _selectedType = null;
      _feeRange = const RangeValues(0, 500000);
      _selectedRanking = null;
      _hasHostel = false;
      _minRating = null;
    });
  }

  void _applyFilters() {
    final provider = context.read<CollegeProvider>();
    
    provider.updateFilters(
      state: _selectedState,
      courseType: _selectedType,
      minFees: _feeRange.start.round(),
      maxFees: _feeRange.end.round(),
    );
    
    // Apply additional filters
    if (_minRating != null) {
      provider.setFilter('minRating', _minRating);
    }
    if (_hasHostel) {
      provider.setFilter('hasHostel', true);
    }
    if (_selectedRanking != null) {
      provider.setFilter('ranking', _selectedRanking);
    }
    
    provider.fetchColleges(refresh: true);
    Navigator.pop(context);
  }
} 