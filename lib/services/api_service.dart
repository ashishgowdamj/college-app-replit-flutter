import 'package:dio/dio.dart';
import '../models/college.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/review.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // College APIs
  Future<List<College>> getColleges({
    String? search,
    String? location,
    String? state,
    String? courseType,
    int? minFees,
    int? maxFees,
    String? entranceExam,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (location != null) queryParams['location'] = location;
      if (state != null) queryParams['state'] = state;
      if (courseType != null) queryParams['courseType'] = courseType;
      if (minFees != null) queryParams['minFees'] = minFees;
      if (maxFees != null) queryParams['maxFees'] = maxFees;
      if (entranceExam != null) queryParams['entranceExam'] = entranceExam;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get('/colleges', queryParameters: queryParams);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => College.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch colleges: ${e.message}');
    }
  }

  Future<College?> getCollege(int id) async {
    try {
      final response = await _dio.get('/colleges/$id');
      return College.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Failed to fetch college: ${e.message}');
    }
  }

  Future<List<Review>> getCollegeReviews(int collegeId) async {
    try {
      final response = await _dio.get('/colleges/$collegeId/reviews');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch reviews: ${e.message}');
    }
  }

  Future<Review> createReview(int collegeId, Map<String, dynamic> reviewData) async {
    try {
      final response = await _dio.post('/colleges/$collegeId/reviews', data: reviewData);
      return Review.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create review: ${e.message}');
    }
  }

  // Exam APIs
  Future<List<Exam>> getExams() async {
    try {
      final response = await _dio.get('/exams');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Exam.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch exams: ${e.message}');
    }
  }

  Future<Exam?> getExam(int id) async {
    try {
      final response = await _dio.get('/exams/$id');
      return Exam.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Failed to fetch exam: ${e.message}');
    }
  }

  // College Predictor API
  Future<List<College>> predictColleges({
    required int score,
    required String exam,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post('/predict-colleges', data: {
        'score': score,
        'exam': exam,
        'preferences': preferences,
      });
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => College.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to predict colleges: ${e.message}');
    }
  }
}