import 'package:flutter/foundation.dart';
import '../models/college.dart';
import '../models/review.dart';
import 'api_service.dart';

class CollegeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<College> _colleges = [];
  List<College> _favoriteColleges = [];
  College? _selectedCollege;
  List<Review> _selectedCollegeReviews = [];
  bool _isLoading = false;
  String? _error;
  
  // Search and filter state
  String _searchQuery = '';
  String? _selectedState;
  String? _selectedCourseType;
  int? _minFees;
  int? _maxFees;

  // Getters
  List<College> get colleges => _colleges;
  List<College> get favoriteColleges => _favoriteColleges;
  College? get selectedCollege => _selectedCollege;
  List<Review> get selectedCollegeReviews => _selectedCollegeReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedState => _selectedState;
  String? get selectedCourseType => _selectedCourseType;
  int? get minFees => _minFees;
  int? get maxFees => _maxFees;

  // Search and filter methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilters({
    String? state,
    String? courseType,
    int? minFees,
    int? maxFees,
  }) {
    _selectedState = state;
    _selectedCourseType = courseType;
    _minFees = minFees;
    _maxFees = maxFees;
    notifyListeners();
  }

  void clearFilters() {
    _selectedState = null;
    _selectedCourseType = null;
    _minFees = null;
    _maxFees = null;
    notifyListeners();
  }

  // Fetch colleges with current filters
  Future<void> fetchColleges() async {
    _setLoading(true);
    try {
      _colleges = await _apiService.getColleges(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        state: _selectedState,
        courseType: _selectedCourseType,
        minFees: _minFees,
        maxFees: _maxFees,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _colleges = [];
    } finally {
      _setLoading(false);
    }
  }

  // Fetch college details
  Future<void> fetchCollegeDetails(int collegeId) async {
    _setLoading(true);
    try {
      _selectedCollege = await _apiService.getCollege(collegeId);
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
}