import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/college.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/review.dart';

class CollegePage {
  final List<College> items;
  final Map<String, dynamic>? nextCursor;
  final bool hasMore;
  final int totalFetched;

  CollegePage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.totalFetched,
  });
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lightweight page container for paginated queries
  // nextCursor contains the values to pass back into startAfter
  // Example: { 'rank': 25, 'name': 'Indian Institute of ...' }
  // Keep this here to avoid introducing Firestore types in UI layers
  // and to avoid adding a new model file for a simple container.
  // You can move this to its own file later if preferred.
  static const _cursorRankKey = 'rank';
  static const _cursorNameKey = 'name';

  /// Result of a paginated fetch
  /// items: list of colleges
  /// nextCursor: map with keys 'rank' (int?) and 'name' (String?) to be supplied back to fetch next page
  /// hasMore: whether additional pages likely exist
  /// totalFetched: count in this page
  /// Note: Search is still client-side substring filter on name/shortName/location.
  ///       If search is used, effective page size may be < limit due to post-filtering.
  Future<CollegePage> getCollegesPaginated({
    int limit = 20,
    String? state,
    String? search,
    Map<String, dynamic>? cursor,
  }) async {
    try {
      Query query = _firestore.collection('colleges');

      // TEMP: Avoid server-side state filter to prevent composite index requirement.
      // The provider applies state filtering client-side for now.
      // if (state != null && state.isNotEmpty) {
      //   query = query.where('state', isEqualTo: state);
      // }

      // TEMP: Order only by overallRank to avoid requiring a composite index
      // Once the composite index is created, we can re-add name as a tiebreaker.
      query = query.orderBy('overallRank', descending: false);

      if (cursor != null) {
        final lastRank = cursor[_cursorRankKey];
        // With single-field ordering, we only need to paginate using overallRank
        if (lastRank != null) {
          query = query.startAfter([lastRank]);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      List<College> items = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        items.add(College.fromJson({
          ...data,
          // Keep id backward compatible; our IDs are normalized names not ints
          'id': int.tryParse(doc.id) ?? 0,
        }));
      }

      // Optional client-side search filter
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        items = items.where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.shortName?.toLowerCase().contains(q) ?? false) ||
            c.location.toLowerCase().contains(q)).toList();
      }

      Map<String, dynamic>? nextCursor;
      if (snapshot.docs.isNotEmpty) {
        final last = snapshot.docs.last;
        final ld = last.data() as Map<String, dynamic>;
        // Both camelCase and snake_case exist; prefer camelCase
        final rank = (ld['overallRank'] ?? ld['overall_rank']) as int?;
        final name = (ld['name']) as String?;
        if (rank != null) {
          // Name is optional in cursor when using single-field ordering
          nextCursor = {
            _cursorRankKey: rank,
            if (name != null) _cursorNameKey: name,
          };
        }
      }

      final hasMore = snapshot.docs.length >= limit;

      return CollegePage(
        items: items,
        nextCursor: nextCursor,
        hasMore: hasMore,
        totalFetched: items.length,
      );
    } catch (e) {
      // Rethrow so provider can surface the error to UI (avoids infinite retry loop)
      print('Error fetching paginated colleges: $e');
      rethrow;
    }
  }

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

      if (limit != null) {
        query = query.limit(limit);
      }

      // Offset pagination is inefficient in Firestore; this method remains for backward compatibility
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
        colleges = colleges
            .where((college) =>
                college.name.toLowerCase().contains(searchLower) ||
                college.shortName?.toLowerCase().contains(searchLower) == true ||
                college.location.toLowerCase().contains(searchLower))
            .toList();
      }

      // Apply offset on client-side as a fallback
      if (offset != null) {
        colleges = colleges.skip(offset).toList();
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