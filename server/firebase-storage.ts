import { 
  type College, type InsertCollege,
  type Course, type InsertCourse,
  type Exam, type InsertExam,
  type Review, type InsertReview,
  type Comparison, type InsertComparison,
  type User, type InsertUser
} from "@shared/schema";

import { db } from '../firebase-config.js';

export interface IStorage {
  // College operations
  getColleges(filters?: {
    search?: string;
    location?: string;
    state?: string;
    courseType?: string;
    minFees?: number;
    maxFees?: number;
    entranceExam?: string;
    limit?: number;
    offset?: number;
  }): Promise<College[]>;
  getCollege(id: number): Promise<College | undefined>;
  createCollege(college: InsertCollege): Promise<College>;
  
  // Course operations
  getCoursesByCollege(collegeId: number): Promise<Course[]>;
  getCourse(id: number): Promise<Course | undefined>;
  
  // Exam operations
  getExams(): Promise<Exam[]>;
  getExam(id: number): Promise<Exam | undefined>;
  
  // Review operations
  getReviewsByCollege(collegeId: number): Promise<Review[]>;
  createReview(review: InsertReview): Promise<Review>;
  
  // Comparison operations
  getComparison(id: number): Promise<Comparison | undefined>;
  createComparison(comparison: InsertComparison): Promise<Comparison>;
  
  // User operations
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
}

export class FirebaseStorage implements IStorage {
  
  async getColleges(filters?: {
    search?: string;
    location?: string;
    state?: string;
    courseType?: string;
    minFees?: number;
    maxFees?: number;
    entranceExam?: string;
    limit?: number;
    offset?: number;
  }): Promise<College[]> {
    try {
      let query: any = db.collection('colleges');
      
      // Apply filters
      if (filters?.state) {
        query = query.where('state', '==', filters.state);
      }
      
      if (filters?.minFees !== undefined) {
        query = query.where('fees', '>=', filters.minFees.toString());
      }
      
      if (filters?.maxFees !== undefined) {
        query = query.where('fees', '<=', filters.maxFees.toString());
      }
      
      // Order by rank
      query = query.orderBy('overallRank', 'asc');
      
      const snapshot = await query.get();
      let colleges: College[] = [];
      
      snapshot.forEach((doc: any) => {
        colleges.push({
          id: parseInt(doc.id),
          ...doc.data()
        } as College);
      });
      
      // Apply search filter (client-side for better performance)
      if (filters?.search) {
        const searchLower = filters.search.toLowerCase();
        colleges = colleges.filter(college => 
          college.name.toLowerCase().includes(searchLower) ||
          college.shortName?.toLowerCase().includes(searchLower) ||
          college.location.toLowerCase().includes(searchLower)
        );
      }
      
      // Apply pagination
      if (filters?.offset) {
        colleges = colleges.slice(filters.offset);
      }
      
      if (filters?.limit) {
        colleges = colleges.slice(0, filters.limit);
      }
      
      return colleges;
    } catch (error) {
      console.error('Error fetching colleges:', error);
      return [];
    }
  }

  async getCollege(id: number): Promise<College | undefined> {
    try {
      const doc = await db.collection('colleges').doc(id.toString()).get();
      if (doc.exists) {
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as College;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching college:', error);
      return undefined;
    }
  }

  async createCollege(insertCollege: InsertCollege): Promise<College> {
    try {
      const docRef = await db.collection('colleges').add({
        ...insertCollege,
        createdAt: new Date()
      });
      
      return {
        id: parseInt(docRef.id),
        ...insertCollege,
        createdAt: new Date()
      } as College;
    } catch (error) {
      console.error('Error creating college:', error);
      throw error;
    }
  }

  async getCoursesByCollege(collegeId: number): Promise<Course[]> {
    try {
      const snapshot = await db.collection('courses')
        .where('collegeId', '==', collegeId)
        .get();
      
      const courses: Course[] = [];
      snapshot.forEach((doc: any) => {
        courses.push({
          id: parseInt(doc.id),
          ...doc.data()
        } as Course);
      });
      
      return courses;
    } catch (error) {
      console.error('Error fetching courses:', error);
      return [];
    }
  }

  async getCourse(id: number): Promise<Course | undefined> {
    try {
      const doc = await db.collection('courses').doc(id.toString()).get();
      if (doc.exists) {
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as Course;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching course:', error);
      return undefined;
    }
  }

  async getExams(): Promise<Exam[]> {
    try {
      const snapshot = await db.collection('exams').get();
      const exams: Exam[] = [];
      
      snapshot.forEach((doc: any) => {
        exams.push({
          id: parseInt(doc.id),
          ...doc.data()
        } as Exam);
      });
      
      return exams;
    } catch (error) {
      console.error('Error fetching exams:', error);
      return [];
    }
  }

  async getExam(id: number): Promise<Exam | undefined> {
    try {
      const doc = await db.collection('exams').doc(id.toString()).get();
      if (doc.exists) {
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as Exam;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching exam:', error);
      return undefined;
    }
  }

  async getReviewsByCollege(collegeId: number): Promise<Review[]> {
    try {
      const snapshot = await db.collection('reviews')
        .where('collegeId', '==', collegeId)
        .orderBy('createdAt', 'desc')
        .get();
      
      const reviews: Review[] = [];
      snapshot.forEach((doc: any) => {
        reviews.push({
          id: parseInt(doc.id),
          ...doc.data()
        } as Review);
      });
      
      return reviews;
    } catch (error) {
      console.error('Error fetching reviews:', error);
      return [];
    }
  }

  async createReview(insertReview: InsertReview): Promise<Review> {
    try {
      const docRef = await db.collection('reviews').add({
        ...insertReview,
        createdAt: new Date()
      });
      
      return {
        id: parseInt(docRef.id),
        ...insertReview,
        createdAt: new Date()
      } as Review;
    } catch (error) {
      console.error('Error creating review:', error);
      throw error;
    }
  }

  async getComparison(id: number): Promise<Comparison | undefined> {
    try {
      const doc = await db.collection('comparisons').doc(id.toString()).get();
      if (doc.exists) {
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as Comparison;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching comparison:', error);
      return undefined;
    }
  }

  async createComparison(insertComparison: InsertComparison): Promise<Comparison> {
    try {
      const docRef = await db.collection('comparisons').add({
        ...insertComparison,
        createdAt: new Date()
      });
      
      return {
        id: parseInt(docRef.id),
        ...insertComparison,
        createdAt: new Date()
      } as Comparison;
    } catch (error) {
      console.error('Error creating comparison:', error);
      throw error;
    }
  }

  async getUser(id: number): Promise<User | undefined> {
    try {
      const doc = await db.collection('users').doc(id.toString()).get();
      if (doc.exists) {
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as User;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching user:', error);
      return undefined;
    }
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    try {
      const snapshot = await db.collection('users')
        .where('username', '==', username)
        .limit(1)
        .get();
      
      if (!snapshot.empty) {
        const doc = snapshot.docs[0];
        return {
          id: parseInt(doc.id),
          ...doc.data()
        } as User;
      }
      return undefined;
    } catch (error) {
      console.error('Error fetching user by username:', error);
      return undefined;
    }
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    try {
      const docRef = await db.collection('users').add({
        ...insertUser,
        createdAt: new Date()
      });
      
      return {
        id: parseInt(docRef.id),
        ...insertUser,
        createdAt: new Date()
      } as User;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }
}

export const firebaseStorage = new FirebaseStorage(); 