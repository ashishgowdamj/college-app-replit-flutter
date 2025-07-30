import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/college_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<CollegeProvider>();
    _controller.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search colleges, courses, exams...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context.read<CollegeProvider>().updateSearchQuery('');
                    context.read<CollegeProvider>().fetchColleges();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showFilterDialog(context),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          context.read<CollegeProvider>().updateSearchQuery(value);
        },
        onSubmitted: (value) {
          context.read<CollegeProvider>().fetchColleges();
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<CollegeProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => FilterModal(
          scrollController: scrollController,
          provider: provider,
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final ScrollController scrollController;
  final CollegeProvider provider;

  const FilterModal({
    super.key,
    required this.scrollController,
    required this.provider,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? selectedState;
  String? selectedCourseType;
  RangeValues? feesRange;

  final List<String> states = [
    'Andhra Pradesh', 'Bihar', 'Delhi', 'Gujarat', 'Haryana', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Punjab', 'Rajasthan',
    'Tamil Nadu', 'Telangana', 'Uttar Pradesh', 'West Bengal'
  ];

  final List<String> courseTypes = [
    'Engineering', 'Medical', 'Management', 'Arts', 'Science', 'Commerce',
    'Law', 'Architecture', 'Pharmacy', 'Agriculture'
  ];

  @override
  void initState() {
    super.initState();
    selectedState = widget.provider.selectedState;
    selectedCourseType = widget.provider.selectedCourseType;
    
    final minFees = widget.provider.minFees;
    final maxFees = widget.provider.maxFees;
    if (minFees != null && maxFees != null) {
      feesRange = RangeValues(minFees.toDouble(), maxFees.toDouble());
    } else {
      feesRange = const RangeValues(0, 1000000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedState = null;
                    selectedCourseType = null;
                    feesRange = const RangeValues(0, 1000000);
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // State filter
                Text(
                  'State',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select State',
                  ),
                  items: states.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Course type filter
                Text(
                  'Course Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCourseType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select Course Type',
                  ),
                  items: courseTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourseType = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Fees range filter
                Text(
                  'Fees Range (₹)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: feesRange!,
                  min: 0,
                  max: 1000000,
                  divisions: 20,
                  labels: RangeLabels(
                    '₹${(feesRange!.start / 1000).round()}K',
                    '₹${(feesRange!.end / 1000).round()}K',
                  ),
                  onChanged: (values) {
                    setState(() {
                      feesRange = values;
                    });
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.updateFilters(
                  state: selectedState,
                  courseType: selectedCourseType,
                  minFees: feesRange!.start.round(),
                  maxFees: feesRange!.end.round(),
                );
                widget.provider.fetchColleges();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}