import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/college.dart';
import '../models/exam.dart';
import '../models/review.dart';

class ApiService {
  // Use local backend for testing
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Android emulator localhost
  // Fallback to mock data if server is not available
  static const bool useMockData =
      true; // Set to true temporarily to test with mock data

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
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (courseType != null && courseType.isNotEmpty) {
        // Map courseType to the appropriate backend filter
        if (courseType.toLowerCase() == 'medical') {
          queryParams['entranceExam'] = 'NEET';
        } else if (courseType.toLowerCase() == 'management') {
          queryParams['entranceExam'] = 'CAT';
        } else if (courseType.toLowerCase() == 'iit') {
          queryParams['entranceExam'] = 'JEE Advanced';
        } else {
          queryParams['courseType'] = courseType;
        }
      }
      if (minFees != null && minFees > 0)
        queryParams['minFees'] = minFees.toString();
      if (maxFees != null && maxFees > 0)
        queryParams['maxFees'] = maxFees.toString();
      if (entranceExam != null && entranceExam.isNotEmpty)
        queryParams['entranceExam'] = entranceExam;
      if (limit != null && limit > 0) queryParams['limit'] = limit.toString();
      if (offset != null && offset > 0)
        queryParams['offset'] = offset.toString();

      print('Making API call to: $baseUrl/colleges with params: $queryParams');
      final response =
          await _dio.get('/colleges', queryParameters: queryParams);

      print('API response status: ${response.statusCode}');
      print(
          'API response data length: ${response.data is List ? (response.data as List).length : 'not a list'}');

      if (response.data is List) {
        final colleges = (response.data as List)
            .map((json) => College.fromJson(json))
            .toList();
        print('Parsed ${colleges.length} colleges from API');
        return colleges;
      }
      print('Response data is not a list: ${response.data.runtimeType}');
      return [];
    } catch (e) {
      print('Error fetching colleges from backend: $e');
      print('Error type: ${e.runtimeType}');
      if (e is DioException) {
        print('DioException response: ${e.response?.data}');
        print('DioException status: ${e.response?.statusCode}');
      }
      // Fallback to mock data if backend fails
      print('Falling back to mock data');
      return _getMockColleges();
    }
  }

  Future<College?> getCollege(int id) async {
    if (useMockData) {
      final colleges = _getMockColleges();
      try {
        return colleges.firstWhere((college) => college.id == id);
      } catch (e) {
        return null;
      }
    }

    try {
      final response = await _dio.get('/colleges/$id');
      return College.fromJson(response.data);
    } catch (e) {
      print('Error fetching college from backend: $e');
      // Fallback to mock data
      final colleges = _getMockColleges();
      try {
        return colleges.firstWhere((college) => college.id == id);
      } catch (e) {
        return null;
      }
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

  Future<Review> createReview(
      int collegeId, Map<String, dynamic> reviewData) async {
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
      final response =
          await _dio.post('/colleges/$collegeId/reviews', data: reviewData);
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
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
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
        imageUrl:
            "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
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
        imageUrl:
            "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
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
        imageUrl:
            "https://images.unsplash.com/photo-1523050854058-8df90110c9d1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
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
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
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
      College(
        id: 6,
        name: "Indian Institute of Technology Madras",
        shortName: "IIT Madras",
        location: "Chennai, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Chennai",
        establishedYear: 1959,
        type: "Government",
        affiliation: "IIT System",
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier engineering institute with strong research focus",
        website: "https://www.iitm.ac.in/",
        overallRank: 3,
        nirfRank: 1,
        fees: "248000",
        feesPeriod: "yearly",
        rating: "4.7",
        reviewCount: 1876,
        admissionProcess: "JEE Advanced",
        cutoffScore: 99,
        placementRate: "94",
        averagePackage: "1780000",
        highestPackage: "19800000",
        hostelFees: "22000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 7,
        name: "BITS Pilani",
        shortName: "BITS Pilani",
        location: "Pilani, Rajasthan",
        state: "Rajasthan",
        city: "Pilani",
        establishedYear: 1964,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier private engineering institution",
        website: "https://www.bits-pilani.ac.in/",
        overallRank: 15,
        nirfRank: 25,
        fees: "450000",
        feesPeriod: "yearly",
        rating: "4.3",
        reviewCount: 2876,
        admissionProcess: "BITSAT",
        cutoffScore: 85,
        placementRate: "92",
        averagePackage: "1450000",
        highestPackage: "6500000",
        hostelFees: "65000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 8,
        name: "Delhi Technological University",
        shortName: "DTU",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1941,
        type: "Government",
        affiliation: "State University",
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Leading state engineering university",
        website: "http://www.dtu.ac.in/",
        overallRank: 35,
        nirfRank: 58,
        fees: "156000",
        feesPeriod: "yearly",
        rating: "4.2",
        reviewCount: 1654,
        admissionProcess: "JEE Main",
        cutoffScore: 75,
        placementRate: "85",
        averagePackage: "850000",
        highestPackage: "4200000",
        hostelFees: "45000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 9,
        name: "Vellore Institute of Technology",
        shortName: "VIT Vellore",
        location: "Vellore, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Vellore",
        establishedYear: 1984,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl:
            "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Leading private engineering university",
        website: "https://vit.ac.in/",
        overallRank: 20,
        nirfRank: 16,
        fees: "380000",
        feesPeriod: "yearly",
        rating: "4.1",
        reviewCount: 3245,
        admissionProcess: "VITEEE",
        cutoffScore: 60,
        placementRate: "80",
        averagePackage: "720000",
        highestPackage: "4160000",
        hostelFees: "55000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 10,
        name: "Christian Medical College Vellore",
        shortName: "CMC Vellore",
        location: "Vellore, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Vellore",
        establishedYear: 1900,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl:
            "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier Christian medical college",
        website: "https://www.cmch-vellore.edu/",
        overallRank: 2,
        nirfRank: 2,
        fees: "95000",
        feesPeriod: "yearly",
        rating: "4.8",
        reviewCount: 1200,
        admissionProcess: "NEET",
        cutoffScore: 95,
        placementRate: "100",
        averagePackage: "1120000",
        highestPackage: "2200000",
        hostelFees: "35000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 11,
        name: "Armed Forces Medical College",
        shortName: "AFMC Pune",
        location: "Pune, Maharashtra",
        state: "Maharashtra",
        city: "Pune",
        establishedYear: 1948,
        type: "Government",
        affiliation: "Armed Forces",
        imageUrl:
            "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Military medical college with free education",
        website: "https://www.afmc.nic.in/",
        overallRank: 5,
        nirfRank: 8,
        fees: "0",
        feesPeriod: "yearly",
        rating: "4.6",
        reviewCount: 456,
        admissionProcess: "NEET + AFMC Entrance",
        cutoffScore: 92,
        placementRate: "100",
        averagePackage: "1550000",
        highestPackage: "2500000",
        hostelFees: "0",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 12,
        name: "Indian Institute of Management Bangalore",
        shortName: "IIM Bangalore",
        location: "Bangalore, Karnataka",
        state: "Karnataka",
        city: "Bangalore",
        establishedYear: 1973,
        type: "Government",
        affiliation: "IIM System",
        imageUrl:
            "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Top business school with excellent placements",
        website: "https://www.iimb.ac.in/",
        overallRank: 2,
        nirfRank: 3,
        fees: "2400000",
        feesPeriod: "total",
        rating: "4.6",
        reviewCount: 987,
        admissionProcess: "CAT",
        cutoffScore: 90,
        placementRate: "100",
        averagePackage: "2680000",
        highestPackage: "6150000",
        hostelFees: "85000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 13,
        name: "Xavier Labour Relations Institute",
        shortName: "XLRI Jamshedpur",
        location: "Jamshedpur, Jharkhand",
        state: "Jharkhand",
        city: "Jamshedpur",
        establishedYear: 1955,
        type: "Private",
        affiliation: "Autonomous",
        imageUrl:
            "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier HR and management institute",
        website: "https://www.xlri.ac.in/",
        overallRank: 8,
        nirfRank: 11,
        fees: "1650000",
        feesPeriod: "total",
        rating: "4.4",
        reviewCount: 654,
        admissionProcess: "XAT",
        cutoffScore: 85,
        placementRate: "98",
        averagePackage: "1920000",
        highestPackage: "4500000",
        hostelFees: "75000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 14,
        name: "National Law School of India University",
        shortName: "NLSIU Bangalore",
        location: "Bangalore, Karnataka",
        state: "Karnataka",
        city: "Bangalore",
        establishedYear: 1987,
        type: "Government",
        affiliation: "State University",
        imageUrl:
            "https://images.unsplash.com/photo-1589578228447-e1a4e481c6c8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier law school in India",
        website: "https://www.nls.ac.in/",
        overallRank: 1,
        nirfRank: 1,
        fees: "345000",
        feesPeriod: "yearly",
        rating: "4.7",
        reviewCount: 567,
        admissionProcess: "CLAT",
        cutoffScore: 95,
        placementRate: "95",
        averagePackage: "1250000",
        highestPackage: "3500000",
        hostelFees: "85000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 15,
        name: "Faculty of Law Delhi University",
        shortName: "DU Law",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1924,
        type: "Government",
        affiliation: "Central University",
        imageUrl:
            "https://images.unsplash.com/photo-1589578228447-e1a4e481c6c8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Historic law faculty with affordable education",
        website: "https://lawfaculty.du.ac.in/",
        overallRank: 4,
        nirfRank: 6,
        fees: "25000",
        feesPeriod: "yearly",
        rating: "4.3",
        reviewCount: 1234,
        admissionProcess: "DU LLB Entrance",
        cutoffScore: 70,
        placementRate: "75",
        averagePackage: "650000",
        highestPackage: "1800000",
        hostelFees: "35000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 16,
        name: "St. Xavier's College Mumbai",
        shortName: "St. Xavier's Mumbai",
        location: "Mumbai, Maharashtra",
        state: "Maharashtra",
        city: "Mumbai",
        establishedYear: 1869,
        type: "Private",
        affiliation: "University of Mumbai",
        imageUrl:
            "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier arts and science college",
        website: "https://www.xaviers.edu/",
        overallRank: 2,
        nirfRank: 5,
        fees: "85000",
        feesPeriod: "yearly",
        rating: "4.5",
        reviewCount: 1876,
        admissionProcess: "Merit-based",
        cutoffScore: 85,
        placementRate: "70",
        averagePackage: "450000",
        highestPackage: "1200000",
        hostelFees: "95000",
        hasHostel: false,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 17,
        name: "Jawaharlal Nehru University",
        shortName: "JNU",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1969,
        type: "Government",
        affiliation: "Central University",
        imageUrl:
            "https://images.unsplash.com/photo-1607237138185-eedd9c632b0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier university for social sciences and liberal arts",
        website: "https://www.jnu.ac.in/",
        overallRank: 2,
        nirfRank: 2,
        fees: "25000",
        feesPeriod: "yearly",
        rating: "4.3",
        reviewCount: 1500,
        admissionProcess: "JNU Entrance Exam",
        cutoffScore: 85,
        placementRate: "75",
        averagePackage: "800000",
        highestPackage: "1500000",
        hostelFees: "12000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 18,
        name: "Indian Agricultural Research Institute",
        shortName: "IARI Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1905,
        type: "Government",
        affiliation: "ICAR",
        imageUrl:
            "https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier agricultural research institute",
        website: "https://www.iari.res.in/",
        overallRank: 1,
        nirfRank: 1,
        fees: "35000",
        feesPeriod: "yearly",
        rating: "4.4",
        reviewCount: 789,
        admissionProcess: "ICAR AIEEA",
        cutoffScore: 80,
        placementRate: "90",
        averagePackage: "680000",
        highestPackage: "1800000",
        hostelFees: "25000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 19,
        name: "Shri Ram College of Commerce",
        shortName: "SRCC Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1926,
        type: "Government",
        affiliation: "University of Delhi",
        imageUrl:
            "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Top commerce college with excellent placements",
        website: "https://srcc.edu/",
        overallRank: 1,
        nirfRank: 2,
        fees: "48000",
        feesPeriod: "yearly",
        rating: "4.7",
        reviewCount: 2134,
        admissionProcess: "DU Entrance",
        cutoffScore: 98,
        placementRate: "95",
        averagePackage: "850000",
        highestPackage: "2500000",
        hostelFees: "65000",
        hasHostel: false,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 20,
        name: "School of Planning and Architecture",
        shortName: "SPA Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1941,
        type: "Government",
        affiliation: "Institute of National Importance",
        imageUrl:
            "https://images.unsplash.com/photo-1503387762-592deb58ef4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier architecture and planning school",
        website: "https://www.spa.ac.in/",
        overallRank: 1,
        nirfRank: 1,
        fees: "185000",
        feesPeriod: "yearly",
        rating: "4.5",
        reviewCount: 456,
        admissionProcess: "NATA, JEE Paper 2",
        cutoffScore: 85,
        placementRate: "88",
        averagePackage: "920000",
        highestPackage: "2800000",
        hostelFees: "45000",
        hasHostel: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      College(
        id: 21,
        name: "Lady Shri Ram College",
        shortName: "LSR Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1956,
        type: "Government",
        affiliation: "University of Delhi",
        imageUrl:
            "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier women's college for arts and commerce",
        website: "https://www.lsr.edu.in/",
        overallRank: 3,
        nirfRank: 4,
        fees: "45000",
        feesPeriod: "yearly",
        rating: "4.6",
        reviewCount: 1543,
        admissionProcess: "DU Entrance",
        cutoffScore: 95,
        placementRate: "85",
        averagePackage: "520000",
        highestPackage: "1500000",
        hostelFees: "55000",
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
        createdAt:
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      Review(
        id: 2,
        collegeId: collegeId,
        rating: "4.8",
        title: "Great Placements",
        content: "Great placement opportunities and campus life.",
        studentName: "Priya Sharma",
        createdAt:
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      ),
      Review(
        id: 3,
        collegeId: collegeId,
        rating: "4.2",
        title: "Good Environment",
        content: "Good academic environment with modern facilities.",
        studentName: "Amit Patel",
        createdAt:
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
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
        examDate:
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        applicationEndDate:
            DateTime.now().add(const Duration(days: 15)).toIso8601String(),
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
        examDate:
            DateTime.now().add(const Duration(days: 45)).toIso8601String(),
        applicationEndDate:
            DateTime.now().add(const Duration(days: 25)).toIso8601String(),
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
        examDate:
            DateTime.now().add(const Duration(days: 60)).toIso8601String(),
        applicationEndDate:
            DateTime.now().add(const Duration(days: 40)).toIso8601String(),
        eligibility: "Bachelor's degree with 50% marks",
        examPattern: "Computer Based Test",
        duration: "3 hours",
        totalMarks: 300,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
  }
}
