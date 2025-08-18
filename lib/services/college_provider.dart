import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/college.dart';
import '../models/review.dart';
import 'api_service.dart';
import 'firebase_service.dart';

class CollegeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  
  List<College> _colleges = [];
  final List<College> _favoriteColleges = [];
  College? _selectedCollege;
  List<Review> _selectedCollegeReviews = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  
  // Search and filter state
  String _searchQuery = '';
  String? _selectedState;
  String? _selectedCourseType;
  int? _minFees;
  int? _maxFees;
  String? _locationQuery; // city/area free-text filter
  final Map<String, dynamic> _currentFilters = {};
  
  // Pagination state
  bool _hasMoreData = true;
  static const int _pageSize = 20;
  Timer? _searchDebounce;
  Map<String, dynamic>? _cursor; // Firestore pagination cursor

  // Normalize common city/state synonyms and whitespace
  String _normalizePlace(String? s) {
    final x = (s ?? '').trim().toLowerCase();
    if (x.isEmpty) return x;
    // Basic synonyms
    const synonyms = {
      'bengaluru': 'bangalore',
      'bengalooru': 'bangalore',
      'mumbai': 'mumbai',
      'bombay': 'mumbai',
      'kolkata': 'kolkata',
      'calcutta': 'kolkata',
      'pune': 'pune',
      'delhi': 'delhi',
      'new delhi': 'delhi',
      'chennai': 'chennai',
      'madras': 'chennai',
      'bengaluru, karnataka': 'bangalore, karnataka',
    };
    return synonyms[x] ?? x;
  }

  // Getters
  List<College> get colleges => _colleges;
  List<College> get favoriteColleges => _favoriteColleges;
  College? get selectedCollege => _selectedCollege;
  List<Review> get selectedCollegeReviews => _selectedCollegeReviews;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedState => _selectedState;
  String? get selectedCourseType => _selectedCourseType;
  int? get minFees => _minFees;
  int? get maxFees => _maxFees;
  String? get locationQuery => _locationQuery;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoading && _colleges.isNotEmpty;
  Map<String, dynamic> get currentFilters => _currentFilters;

  // Search and filter methods
  Future<void> updateSearchQuery(String query) async {
    print('=== updateSearchQuery() called with query: "$query" ===');
    
    // Only update if query has actually changed
    if (_searchQuery == query) {
      print('Search query unchanged, skipping update');
      return;
    }
    
    print('Updating search query from "$_searchQuery" to "$query"');
    _searchQuery = query;
    
    // Reset pagination when search changes but DO NOT clear current results to avoid flicker
    _resetPagination();
    _isRefreshing = true;
    notifyListeners();

    // Debounce fetch centrally so all pages share the same behavior
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await fetchColleges(refresh: true);
      } catch (e, stackTrace) {
        print('Error in debounced fetch: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

  void setFilter(String key, dynamic value) {
    _currentFilters[key] = value;
    // Update the corresponding filter properties
    switch (key) {
      case 'type':
        _selectedCourseType = value;
        break;
      case 'state':
        _selectedState = value;
        break;
      case 'minFees':
        _minFees = value;
        break;
      case 'maxFees':
        _maxFees = value;
        break;
      case 'location':
        _locationQuery = value;
        break;
    }
    notifyListeners();
  }

  void clearFilter(String key) {
    _currentFilters.remove(key);
    // Clear the corresponding filter properties
    switch (key) {
      case 'type':
        _selectedCourseType = null;
        break;
      case 'state':
        _selectedState = null;
        break;
      case 'minFees':
        _minFees = null;
        break;
      case 'maxFees':
        _maxFees = null;
        break;
      case 'location':
        _locationQuery = null;
        break;
    }
    notifyListeners();
  }

  void updateFilters({
    String? state,
    String? courseType,
    int? minFees,
    int? maxFees,
    String? locationQuery,
  }) {
    _selectedState = state;
    _selectedCourseType = courseType;
    _minFees = minFees;
    _maxFees = maxFees;
    _locationQuery = locationQuery;
    
    // Update current filters map
    _currentFilters.clear();
    if (state != null) _currentFilters['state'] = state;
    if (courseType != null) _currentFilters['type'] = courseType;
    if (minFees != null) _currentFilters['minFees'] = minFees;
    if (maxFees != null) _currentFilters['maxFees'] = maxFees;
    if (locationQuery != null && locationQuery.isNotEmpty) {
      _currentFilters['location'] = locationQuery;
    }
    
    notifyListeners();
  }

  void clearFilters() {
    _selectedState = null;
    _selectedCourseType = null;
    _minFees = null;
    _maxFees = null;
    _locationQuery = null;
    _currentFilters.clear();
    _resetPagination();
    notifyListeners();
  }
  
  void _resetPagination() {
    _hasMoreData = true;
    _cursor = null;
  }

  // Fetch colleges with current filters
  Future<void> fetchColleges({bool refresh = false}) async {
    print('=== fetchColleges called, refresh: $refresh ===');
    
    if (refresh) {
      print('Resetting pagination (keeping current list visible during refresh)');
      _resetPagination();
      _isRefreshing = true;
    } else if (!_hasMoreData) {
      print('No more data to load');
      return;
    }
    
    _setLoading(true);
    _error = null;
    
    try {
      print('Fetching colleges from Firestore with cursor-based pagination...');
      final page = await _firebaseService.getCollegesPaginated(
        limit: _pageSize,
        state: _selectedState,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        cursor: refresh ? null : _cursor,
      );
      final newColleges = page.items;
      _cursor = page.nextCursor;
      print('Fetched ${newColleges.length} colleges from Firestore; hasMore: ${page.hasMore}');
      
      // Apply client-side filtering if needed
      List<College> filteredColleges = List.from(newColleges);
      print('Before filtering: ${filteredColleges.length} colleges');

      // Apply search filter client-side (useful when backend falls back to mock data)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final originalCount = filteredColleges.length;
        filteredColleges = filteredColleges.where((college) {
          final hay = [
            college.name,
            college.shortName ?? '',
            college.location,
            college.city,
            college.state,
            college.type,
          ].join(' ').toLowerCase();
          final include = hay.contains(q);
          if (!include) {
            // Debug which colleges are filtered out by search
            // print('Filtering out by search ("$q"): ${college.name}');
          }
          return include;
        }).toList();
        print('After search filtering: ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }
      
      // Apply course type filter if selected
      if (_selectedCourseType != null) {
        print('Filtering by course type: $_selectedCourseType');
        final originalCount = filteredColleges.length;
        
        final ct = _selectedCourseType!.toLowerCase();
        if (ct == 'engineering' || ct.contains('b.tech') || ct.contains('btech') || ct == 'be' || ct.contains('engineering')) {
          filteredColleges = filteredColleges.where((college) {
            final name = college.name.toLowerCase();
            final type = college.type.toLowerCase();
            final admission = (college.admissionProcess ?? '').toLowerCase();
            final jee = admission.contains('jee');
            final mht = admission.contains('mht-cet') || admission.contains('mhtcet');
            final engKeywords = name.contains('engineering') ||
                name.contains('institute of technology') ||
                name.contains('technology') ||
                type.contains('engineering') ||
                type.contains('technical') ||
                type.contains('iit') || type.contains('nit') || type.contains('iiit');
            final matches = jee || mht || engKeywords;
            if (!matches) {
              print('Filtering out college (engineering): ${college.name} - Admission: ${college.admissionProcess}, Type: ${college.type}');
            }
            return matches;
          }).toList();
        } else if (ct == 'medical' || ct.contains('mbbs') || ct.contains('medicine')) {
          filteredColleges = filteredColleges.where((college) {
            final matches = college.admissionProcess?.toLowerCase().contains('neet') ?? false;
            if (!matches) {
              print('Filtering out college (medical): ${college.name} - Admission: ${college.admissionProcess}');
            }
            return matches;
          }).toList();
        } else if (ct == 'management' || ct.contains('mba')) {
          filteredColleges = filteredColleges.where((college) {
            final admission = college.admissionProcess?.toLowerCase() ?? '';
            final matches = admission.contains('cat') || admission.contains('xat');
            if (!matches) {
              print('Filtering out college (management): ${college.name} - Admission: ${college.admissionProcess}');
            }
            return matches;
          }).toList();
        } else if (ct == 'iit') {
          filteredColleges = filteredColleges.where((college) {
            final matches = college.name.toLowerCase().contains('iit') || 
                          (college.admissionProcess?.toLowerCase().contains('jee advanced') ?? false);
            if (!matches) {
              print('Filtering out college (IIT): ${college.name} - Admission: ${college.admissionProcess}');
            }
            return matches;
          }).toList();
        } else if (ct == 'nit') {
          filteredColleges = filteredColleges.where((college) {
            final matches = college.name.toLowerCase().contains('nit') || 
                          (college.admissionProcess?.toLowerCase().contains('jee main') ?? false);
            if (!matches) {
              print('Filtering out college (NIT): ${college.name} - Admission: ${college.admissionProcess}');
            }
            return matches;
          }).toList();
        }
        
        print('After course type filtering: ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }

      // Apply state filter if selected (client-side)
      if (_selectedState != null && _selectedState!.isNotEmpty) {
        final s = _selectedState!.toLowerCase();
        final originalCount = filteredColleges.length;
        filteredColleges = filteredColleges.where((college) {
          final include = (college.state.toLowerCase() == s) ||
              college.location.toLowerCase().contains(s) ||
              college.city.toLowerCase() == s;
        
          if (!include) {
            // print('Filtering out by state ("$s"): ${college.name} - state: ${college.state}');
          }
          return include;
        }).toList();
        print('After state filtering: ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }

      // Apply location free-text filter (client-side)
      if (_locationQuery != null && _locationQuery!.trim().isNotEmpty) {
        final lq = _locationQuery!.toLowerCase().trim();
        final originalCount = filteredColleges.length;
        filteredColleges = filteredColleges.where((college) {
          final hay = [college.city, college.state, college.location]
              .join(' ').toLowerCase();
          final include = hay.contains(lq);
          return include;
        }).toList();
        print('After location filtering ("$lq"): ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }
      
      // Apply fees filter if set
      if (_minFees != null && _minFees! > 0) {
        final originalCount = filteredColleges.length;
        filteredColleges = filteredColleges.where((college) {
          final fees = double.tryParse(college.fees ?? '0') ?? 0;
          final include = fees >= _minFees!;
          if (!include) {
            print('Filtering out college (min fees): ${college.name} - Fees: ${college.fees} (min: $_minFees)');
          }
          return include;
        }).toList();
        print('After min fees filtering: ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }
      
      if (_maxFees != null && _maxFees! > 0) {
        final originalCount = filteredColleges.length;
        filteredColleges = filteredColleges.where((college) {
          final fees = double.tryParse(college.fees ?? '0') ?? 0;
          final include = fees <= _maxFees!;
          if (!include) {
            print('Filtering out college (max fees): ${college.name} - Fees: ${college.fees} (max: $_maxFees)');
          }
          return include;
        }).toList();
        print('After max fees filtering: ${filteredColleges.length} colleges (filtered out ${originalCount - filteredColleges.length})');
      }
      
      // Prioritize by location: city match first, then state match, then others
      if ((_locationQuery != null && _locationQuery!.trim().isNotEmpty) ||
          (_selectedState != null && _selectedState!.trim().isNotEmpty)) {
        final normQuery = _normalizePlace(_locationQuery);
        final normState = _normalizePlace(_selectedState);
        int score(College c) {
          final city = _normalizePlace(c.city);
          final state = _normalizePlace(c.state);
          final hay = _normalizePlace('${c.city} ${c.state} ${c.location}');
          int s = 0;
          if (normQuery.isNotEmpty) {
            if (city == normQuery) s = 3;
            else if (hay.contains(normQuery)) s = 1; // substring match
          }
          if (normState.isNotEmpty) {
            if (state == normState) s = s < 2 ? 2 : s; // keep higher
          }
          return s;
        }
        filteredColleges.sort((a, b) {
          final sb = score(b);
          final sa = score(a);
          if (sb != sa) return sb.compareTo(sa);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      }

      print('Final filtered colleges count: ${filteredColleges.length}');
      
      if (refresh) {
        // Replace the list after fresh data arrives
        _colleges = filteredColleges;
      } else {
        _colleges.addAll(filteredColleges);
      }
      
      _hasMoreData = page.hasMore;
      
      _error = null;
      print('Updated colleges list. Total colleges: ${_colleges.length}, hasMoreData: $_hasMoreData');
      
      // Print first few colleges for debugging
      final count = _colleges.length > 3 ? 3 : _colleges.length;
      print('First $count colleges:');
      for (var i = 0; i < count; i++) {
        final college = _colleges[i];
        print('${i + 1}. ${college.name} (ID: ${college.id}, Admission: ${college.admissionProcess}, Fees: ${college.fees})');
      }
      
    } catch (e, stackTrace) {
      print('Error in fetchColleges: $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      _setLoading(false);
      print('=== fetchColleges completed ===');
    }
  }
  
  // Load more colleges for pagination
  Future<void> loadMoreColleges() async {
    if (!_hasMoreData || _isLoading) return;
    await fetchColleges();
  }

  // Fetch college details
  Future<void> fetchCollegeDetails(int collegeId) async {
    _setLoading(true);
    try {
      // First try to find the college in the already loaded list
      final existingCollege = _colleges.where((college) => college.id == collegeId).firstOrNull;
      
      if (existingCollege != null) {
        _selectedCollege = existingCollege;
      } else {
        // If not found in loaded list, use mock data for faster loading
        _selectedCollege = null;
      }
      
      if (_selectedCollege != null) {
        _selectedCollegeReviews = await _apiService.getCollegeReviews(collegeId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedCollege = null;
      _selectedCollegeReviews = [];
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite college
  void toggleFavorite(College college) {
    final index = _favoriteColleges.indexWhere((c) => c.id == college.id);
    if (index >= 0) {
      _favoriteColleges.removeAt(index);
    } else {
      _favoriteColleges.add(college);
    }
    notifyListeners();
  }

  bool isFavorite(College college) {
    return _favoriteColleges.any((c) => c.id == college.id);
  }

  // Add review
  Future<void> addReview(int collegeId, Map<String, dynamic> reviewData) async {
    try {
      final review = await _apiService.createReview(collegeId, reviewData);
      _selectedCollegeReviews.insert(0, review);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // College prediction
  Future<List<College>> predictColleges({
    required int score,
    required String exam,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      return await _apiService.predictColleges(
        score: score,
        exam: exam,
        preferences: preferences,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}