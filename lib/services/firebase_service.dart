import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/college.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/review.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // College operations
  Future<List<College>> getColleges({
    String? search,
    String? location,
    String? state,
    String? courseType,
    double? minFees,
    double? maxFees,
    String? entranceExam,
    int? limit,
    int? offset,
  }) async {
    try {
      Query query = _firestore.collection('colleges');
      
      // Apply filters
      if (state != null) {
        query = query.where('state', isEqualTo: state);
      }
      
      if (minFees != null) {
        query = query.where('fees', isGreaterThanOrEqualTo: minFees.toString());
      }
      
      if (maxFees != null) {
        query = query.where('fees', isLessThanOrEqualTo: maxFees.toString());
      }
      
      // Order by rank
      query = query.orderBy('overallRank', descending: false);
      
      QuerySnapshot snapshot = await query.get();
      List<College> colleges = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Convert Firestore document to College object
        colleges.add(College.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0, // Use document ID as college ID
        }));
      }
      
      // Apply search filter
      if (search != null && search.isNotEmpty) {
        String searchLower = search.toLowerCase();
        colleges = colleges.where((college) =>
          college.name.toLowerCase().contains(searchLower) ||
          college.shortName?.toLowerCase().contains(searchLower) == true ||
          college.location.toLowerCase().contains(searchLower)
        ).toList();
      }
      
      // Apply pagination
      if (offset != null) {
        colleges = colleges.skip(offset).toList();
      }
      
      if (limit != null) {
        colleges = colleges.take(limit).toList();
      }
      
      return colleges;
    } catch (e) {
      print('Error fetching colleges: $e');
      return [];
    }
  }

  Future<College?> getCollege(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('colleges').doc(id).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return College.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching college: $e');
      return null;
    }
  }

  Future<List<Course>> getCoursesByCollege(String collegeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courses')
          .where('collegeId', isEqualTo: collegeId)
          .get();
      
      List<Course> courses = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        courses.add(Course.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0,
        }));
      }
      return courses;
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<List<Exam>> getExams() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('exams').get();
      List<Exam> exams = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        exams.add(Exam.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0,
        }));
      }
      return exams;
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  Future<List<Review>> getReviewsByCollege(String collegeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('collegeId', isEqualTo: collegeId)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Review> reviews = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        reviews.add(Review.fromJson({
          ...data,
          'id': int.tryParse(doc.id) ?? 0,
        }));
      }
      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<bool> createReview(Review review) async {
    try {
      await _firestore.collection('reviews').add({
        'collegeId': review.collegeId,
        'rating': review.rating,
        'title': review.title,
        'content': review.content,
        'studentName': review.studentName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  // User authentication
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Favorites management
  Future<List<String>> getUserFavorites() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return [];

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('colleges')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['collegeIds'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String collegeId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentReference docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('colleges');

      DocumentSnapshot doc = await docRef.get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> favorites = List<String>.from(data['collegeIds'] ?? []);
        
        if (favorites.contains(collegeId)) {
          favorites.remove(collegeId);
        } else {
          favorites.add(collegeId);
        }
        
        await docRef.update({'collegeIds': favorites});
      } else {
        await docRef.set({'collegeIds': [collegeId]});
      }
      
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Real-time updates
  Stream<List<College>> getCollegesStream() {
    return _firestore
        .collection('colleges')
        .orderBy('overallRank', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => College.fromJson({
              ...doc.data(),
              'id': int.tryParse(doc.id) ?? 0,
            }))
            .toList());
  }

  Stream<List<Review>> getReviewsStream(String collegeId) {
    return _firestore
        .collection('reviews')
        .where('collegeId', isEqualTo: collegeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromJson({
              ...doc.data(),
              'id': int.tryParse(doc.id) ?? 0,
            }))
            .toList());
  }
} 