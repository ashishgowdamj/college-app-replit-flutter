import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/college_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'dart:async';
import '../services/location_service.dart';
import '../models/location_suggestion.dart';

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search colleges, courses, exams...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    _controller.clear();
                    // Centralized debounce in provider will handle fetch
                    context.read<CollegeProvider>().updateSearchQuery('');
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Choose location',
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () => _showFilterDialog(context),
                    ),
                    IconButton(
                      tooltip: 'Filters',
                      icon: Icon(
                        Icons.tune_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          // Provider contains a debounce and triggers fetch; keep UI simple
          context.read<CollegeProvider>().updateSearchQuery(value);
        },
        onSubmitted: (value) {
          // Optional: rely on provider debounce; no extra fetch to keep behavior consistent
          context.read<CollegeProvider>().updateSearchQuery(value);
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
  String? locationQuery;
  final TextEditingController _locationController = TextEditingController();
  final List<LocationSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isFetching = false;

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
    locationQuery = widget.provider.locationQuery;
    if (locationQuery != null) {
      _locationController.text = locationQuery!;
    }
    
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
                // Location filter
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter city, state or area',
                              suffixIcon: _isFetching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (v) {
                              setState(() {
                                locationQuery = v;
                              });
                              _debouncedFetch(v);
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_suggestions.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 240),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
                                itemBuilder: (context, index) {
                                  final s = _suggestions[index];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(
                                      s.displayName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: (s.city != null || s.state != null)
                                        ? Text([(s.city ?? ''), (s.state ?? '')]
                                            .where((e) => e.isNotEmpty)
                                            .join(', '))
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        locationQuery = s.displayName;
                                        _locationController.text = s.displayName;
                                        // Also set state if available from suggestion
                                        if (s.state != null && s.state!.trim().isNotEmpty) {
                                          selectedState = s.state;
                                        }
                                        _suggestions.clear();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _useMyLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Use my location'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                  locationQuery: (locationQuery ?? _locationController.text).trim().isEmpty
                      ? null
                      : (locationQuery ?? _locationController.text).trim(),
                );
                widget.provider.fetchColleges(refresh: true);
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

  Future<void> _useMyLocation() async {
    try {
      // Check service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied. Enable in Settings.')),
          );
        }
        return;
      }

      // Get position
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      // Reverse geocode
      final places = await gc.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (places.isNotEmpty) {
        final p = places.first;
        final city = p.locality?.trim();
        final state = p.administrativeArea?.trim();
        final loc = [city, state].where((e) => (e ?? '').isNotEmpty).join(', ');
        setState(() {
          locationQuery = loc;
          _locationController.text = loc;
          if ((state ?? '').isNotEmpty) {
            selectedState = state;
          }
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Using location: $loc')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _debouncedFetch(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isFetching = true);
      try {
        final results = await LocationService.searchPlaces(q, countryCodes: 'in', limit: 8);
        if (!mounted) return;
        setState(() {
          _suggestions
            ..clear()
            ..addAll(results);
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _suggestions.clear());
      } finally {
        if (mounted) setState(() => _isFetching = false);
      }
    });
  }
}