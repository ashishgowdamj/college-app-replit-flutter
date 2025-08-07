import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/college.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/review.dart';

class ApiService {
  // Use a public backend URL or mock data for production
  static const String baseUrl = 'https://college-api.onrender.com/api'; // Example public URL
  // Fallback to mock data if server is not available
  static const bool useMockData = false; // Set to false to use Firebase
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
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
    if (useMockData) {
      return _getMockColleges();
    }
    
    try {
      // Use Firebase Firestore
      Query query = FirebaseFirestore.instance.collection('colleges');
      
      // Apply filters
      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }
      
      // Apply fees filters if provided
      if (minFees != null && minFees > 0) {
        query = query.where('fees', isGreaterThanOrEqualTo: minFees.toString());
      }
      
      if (maxFees != null && maxFees > 0) {
        query = query.where('fees', isLessThanOrEqualTo: maxFees.toString());
      }
      
      // Order by rank
      query = query.orderBy('overall_rank', descending: false);
      
      // Apply pagination (Firestore doesn't support offset, so we'll use limit)
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      } else {
        // Default limit to avoid loading too many documents
        query = query.limit(50);
      }
      
      QuerySnapshot snapshot = await query.get();
      List<College> colleges = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        colleges.add(College.fromJson({
          ...data,
          'id': doc.id.hashCode, // Use hashCode of document ID as integer ID
        }));
      }
      
      // Apply search filter (client-side for better flexibility)
      if (search != null && search.isNotEmpty) {
        String searchLower = search.toLowerCase();
        colleges = colleges.where((college) =>
          college.name.toLowerCase().contains(searchLower) ||
          (college.shortName?.toLowerCase().contains(searchLower) ?? false) ||
          college.location.toLowerCase().contains(searchLower) ||
          college.city.toLowerCase().contains(searchLower) ||
          college.state.toLowerCase().contains(searchLower) ||
          (college.description?.toLowerCase().contains(searchLower) ?? false)
        ).toList();
      }
      
      // Apply course type filter
      if (courseType != null && courseType.isNotEmpty) {
        colleges = colleges.where((college) =>
          college.type.toLowerCase().contains(courseType.toLowerCase()) ||
          (college.affiliation?.toLowerCase().contains(courseType.toLowerCase()) ?? false)
        ).toList();
      }
      
      return colleges;
    } catch (e) {
      print('Error fetching colleges from Firebase: $e');
      // Fallback to mock data if Firebase fails
      return _getMockColleges();
    }
  }

  Future<College?> getCollege(int id) async {
    // Always use mock data for faster loading
    final colleges = _getMockColleges();
    try {
      return colleges.firstWhere((college) => college.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Review>> getCollegeReviews(int collegeId) async {
    if (useMockData) {
      return _getMockReviews(collegeId);
    }
    
    try {
      final response = await _dio.get('/colleges/$collegeId/reviews');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } on DioException {
      return _getMockReviews(collegeId);
    }
  }

  Future<Review> createReview(int collegeId, Map<String, dynamic> reviewData) async {
    if (useMockData) {
      // Create a mock review
      return Review(
        id: DateTime.now().millisecondsSinceEpoch,
        collegeId: collegeId,
        rating: (reviewData['rating'] ?? 4.0).toString(),
        title: reviewData['title'] ?? 'Great Experience',
        content: reviewData['comment'] ?? '',
        studentName: reviewData['author'] ?? 'Anonymous',
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    
    try {
      final response = await _dio.post('/colleges/$collegeId/reviews', data: reviewData);
      return Review.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create review: ${e.message}');
    }
  }

  // Exam APIs
  Future<List<Exam>> getExams() async {
    if (useMockData) {
      return _getMockExams();
    }
    
    try {
      final response = await _dio.get('/exams');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Exam.fromJson(json))
            .toList();
      }
      return [];
    } on DioException {
      return _getMockExams();
    }
  }

  Future<Exam?> getExam(int id) async {
    if (useMockData) {
      final exams = _getMockExams();
      try {
        return exams.firstWhere((exam) => exam.id == id);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final response = await _dio.get('/exams/$id');
      return Exam.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final exams = _getMockExams();
      try {
        return exams.firstWhere((exam) => exam.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // College Predictor API
  Future<List<College>> predictColleges({
    required int score,
    required String exam,
    Map<String, dynamic>? preferences,
  }) async {
    if (useMockData) {
      return _getMockColleges().take(5).toList();
    }
    
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
    } on DioException {
      return _getMockColleges().take(5).toList();
    }
  }

  // Mock data methods
  List<College> _getMockColleges() {
    return [
      College(
        id: 1,
        name: "Indian Institute of Technology Delhi",
        shortName: "IIT Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1961,
        type: "Government",
        affiliation: "IIT System",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier engineering and technology institute",
        website: "https://home.iitd.ac.in/",
        overallRank: 1,
        nirfRank: 2,
        fees: "250000",
        feesPeriod: "yearly",
        rating: "4.5",
        reviewCount: 2100,
        admissionProcess: "JEE Advanced",
        cutoffScore: 99,
        placementRate: "95.5",
        averagePackage: "1800000",
        highestPackage: "5000000",
        hostelFees: "25000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 2,
        name: "All India Institute of Medical Sciences",
        shortName: "AIIMS Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1956,
        type: "Government",
        affiliation: "Ministry of Health and Family Welfare",
        imageUrl: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier medical college and hospital",
        website: "https://www.aiims.edu/",
        overallRank: 1,
        nirfRank: 1,
        fees: "130000",
        feesPeriod: "yearly",
        rating: "4.8",
        reviewCount: 1800,
        admissionProcess: "NEET",
        cutoffScore: 98,
        placementRate: "100",
        averagePackage: "1200000",
        highestPackage: "2500000",
        hostelFees: "15000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 3,
        name: "Indian Institute of Management Ahmedabad",
        shortName: "IIM Ahmedabad",
        location: "Ahmedabad, Gujarat",
        state: "Gujarat",
        city: "Ahmedabad",
        establishedYear: 1961,
        type: "Government",
        affiliation: "IIM System",
        imageUrl: "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier business school in India",
        website: "https://www.iima.ac.in/",
        overallRank: 1,
        nirfRank: 1,
        fees: "2500000",
        feesPeriod: "total",
        rating: "4.7",
        reviewCount: 1200,
        admissionProcess: "CAT",
        cutoffScore: 95,
        placementRate: "100",
        averagePackage: "3200000",
        highestPackage: "8500000",
        hostelFees: "80000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 4,
        name: "Indian Institute of Science Bangalore",
        shortName: "IISc Bangalore",
        location: "Bangalore, Karnataka",
        state: "Karnataka",
        city: "Bangalore",
        establishedYear: 1909,
        type: "Government",
        affiliation: "Autonomous",
        imageUrl: "https://images.unsplash.com/photo-1523050854058-8df90110c9d1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier research institute for science and engineering",
        website: "https://www.iisc.ac.in/",
        overallRank: 1,
        nirfRank: 1,
        fees: "22000",
        feesPeriod: "yearly",
        rating: "4.9",
        reviewCount: 850,
        admissionProcess: "KVPY, JEE Advanced, GATE",
        cutoffScore: 99,
        placementRate: "98",
        averagePackage: "2500000",
        highestPackage: "12000000",
        hostelFees: "35000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 5,
        name: "Indian Institute of Technology Bombay",
        shortName: "IIT Bombay",
        location: "Mumbai, Maharashtra",
        state: "Maharashtra",
        city: "Mumbai",
        establishedYear: 1958,
        type: "Government",
        affiliation: "IIT System",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Leading IIT known for engineering excellence",
        website: "https://www.iitb.ac.in/",
        overallRank: 2,
        nirfRank: 3,
        fees: "253000",
        feesPeriod: "yearly",
        rating: "4.6",
        reviewCount: 1950,
        admissionProcess: "JEE Advanced",
        cutoffScore: 99,
        placementRate: "96",
        averagePackage: "1900000",
        highestPackage: "14500000",
        hostelFees: "28000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  List<Review> _getMockReviews(int collegeId) {
    return [
      Review(
        id: 1,
        collegeId: collegeId,
        rating: "4.5",
        title: "Excellent Experience",
        content: "Excellent infrastructure and faculty. Highly recommended!",
        studentName: "Rahul Kumar",
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      Review(
        id: 2,
        collegeId: collegeId,
        rating: "4.8",
        title: "Great Placements",
        content: "Great placement opportunities and campus life.",
        studentName: "Priya Sharma",
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      ),
      Review(
        id: 3,
        collegeId: collegeId,
        rating: "4.2",
        title: "Good Environment",
        content: "Good academic environment with modern facilities.",
        studentName: "Amit Patel",
        createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      ),
    ];
  }

  List<Exam> _getMockExams() {
    return [
      Exam(
        id: 1,
        name: "JEE Main",
        fullName: "Joint Entrance Examination Main",
        type: "Engineering",
        website: "https://jeemain.nta.nic.in/",
        examDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        applicationEndDate: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        eligibility: "Class 12 pass with Physics, Chemistry, Mathematics",
        examPattern: "Computer Based Test",
        duration: "3 hours",
        totalMarks: 300,
        createdAt: DateTime.now().toIso8601String(),
      ),
      Exam(
        id: 2,
        name: "NEET",
        fullName: "National Eligibility cum Entrance Test",
        type: "Medical",
        website: "https://neet.nta.nic.in/",
        examDate: DateTime.now().add(const Duration(days: 45)).toIso8601String(),
        applicationEndDate: DateTime.now().add(const Duration(days: 25)).toIso8601String(),
        eligibility: "Class 12 pass with Physics, Chemistry, Biology",
        examPattern: "Pen and Paper Based Test",
        duration: "3 hours 20 minutes",
        totalMarks: 720,
        createdAt: DateTime.now().toIso8601String(),
      ),
      Exam(
        id: 3,
        name: "CAT",
        fullName: "Common Admission Test",
        type: "Management",
        website: "https://iimcat.ac.in/",
        examDate: DateTime.now().add(const Duration(days: 60)).toIso8601String(),
        applicationEndDate: DateTime.now().add(const Duration(days: 40)).toIso8601String(),
        eligibility: "Bachelor's degree with 50% marks",
        examPattern: "Computer Based Test",
        duration: "3 hours",
        totalMarks: 300,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
  }
}