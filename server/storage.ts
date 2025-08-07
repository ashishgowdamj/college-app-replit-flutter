import { 
  colleges, courses, exams, reviews, comparisons, users,
  type College, type InsertCollege,
  type Course, type InsertCourse,
  type Exam, type InsertExam,
  type Review, type InsertReview,
  type Comparison, type InsertComparison,
  type User, type InsertUser
} from "@shared/schema";

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

export class MemStorage implements IStorage {
  private colleges: Map<number, College>;
  private courses: Map<number, Course>;
  private exams: Map<number, Exam>;
  private reviews: Map<number, Review>;
  private comparisons: Map<number, Comparison>;
  private users: Map<number, User>;
  private currentCollegeId: number;
  private currentCourseId: number;
  private currentExamId: number;
  private currentReviewId: number;
  private currentComparisonId: number;
  private currentUserId: number;

  constructor() {
    this.colleges = new Map();
    this.courses = new Map();
    this.exams = new Map();
    this.reviews = new Map();
    this.comparisons = new Map();
    this.users = new Map();
    this.currentCollegeId = 1;
    this.currentCourseId = 1;
    this.currentExamId = 1;
    this.currentReviewId = 1;
    this.currentComparisonId = 1;
    this.currentUserId = 1;
    
    this.seedData();
  }

  private seedData() {
    // Seed colleges
    const collegesData: InsertCollege[] = [
      {
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
        nirf_rank: 2,
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
      },
      {
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
        nirf_rank: 1,
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
      },
      {
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
        nirf_rank: 1,
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
      },
      {
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
        nirf_rank: 1,
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
      },
      {
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
        nirf_rank: 3,
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
      },
      {
        name: "Indian Institute of Technology Madras",
        shortName: "IIT Madras",
        location: "Chennai, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Chennai",
        establishedYear: 1959,
        type: "Government",
        affiliation: "IIT System",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier engineering institute with strong research focus",
        website: "https://www.iitm.ac.in/",
        overallRank: 3,
        nirf_rank: 1,
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
      },
      {
        name: "BITS Pilani",
        shortName: "BITS Pilani",
        location: "Pilani, Rajasthan",
        state: "Rajasthan",
        city: "Pilani",
        establishedYear: 1964,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier private engineering institution",
        website: "https://www.bits-pilani.ac.in/",
        overallRank: 15,
        nirf_rank: 25,
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
      },
      {
        name: "Delhi Technological University",
        shortName: "DTU",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1941,
        type: "Government",
        affiliation: "State University",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Leading state engineering university",
        website: "http://www.dtu.ac.in/",
        overallRank: 35,
        nirf_rank: 58,
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
      },
      {
        name: "Vellore Institute of Technology",
        shortName: "VIT Vellore",
        location: "Vellore, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Vellore",
        establishedYear: 1984,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Leading private engineering university",
        website: "https://vit.ac.in/",
        overallRank: 20,
        nirf_rank: 16,
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
      },
      {
        name: "Christian Medical College Vellore",
        shortName: "CMC Vellore",
        location: "Vellore, Tamil Nadu",
        state: "Tamil Nadu",
        city: "Vellore",
        establishedYear: 1900,
        type: "Private",
        affiliation: "Deemed University",
        imageUrl: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier Christian medical college",
        website: "https://www.cmch-vellore.edu/",
        overallRank: 2,
        nirf_rank: 2,
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
      },
      {
        name: "Armed Forces Medical College",
        shortName: "AFMC Pune",
        location: "Pune, Maharashtra",
        state: "Maharashtra",
        city: "Pune",
        establishedYear: 1948,
        type: "Government",
        affiliation: "Armed Forces",
        imageUrl: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Military medical college with free education",
        website: "https://www.afmc.nic.in/",
        overallRank: 5,
        nirf_rank: 8,
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
      },
      {
        name: "Indian Institute of Management Bangalore",
        shortName: "IIM Bangalore",
        location: "Bangalore, Karnataka",
        state: "Karnataka",
        city: "Bangalore",
        establishedYear: 1973,
        type: "Government",
        affiliation: "IIM System",
        imageUrl: "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Top business school with excellent placements",
        website: "https://www.iimb.ac.in/",
        overallRank: 2,
        nirf_rank: 3,
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
      },
      {
        name: "Xavier Labour Relations Institute",
        shortName: "XLRI Jamshedpur",
        location: "Jamshedpur, Jharkhand",
        state: "Jharkhand",
        city: "Jamshedpur",
        establishedYear: 1955,
        type: "Private",
        affiliation: "Autonomous",
        imageUrl: "https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier HR and management institute",
        website: "https://www.xlri.ac.in/",
        overallRank: 8,
        nirf_rank: 11,
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
      },
      {
        name: "National Law School of India University",
        shortName: "NLSIU Bangalore",
        location: "Bangalore, Karnataka",
        state: "Karnataka",
        city: "Bangalore",
        establishedYear: 1987,
        type: "Government",
        affiliation: "State University",
        imageUrl: "https://images.unsplash.com/photo-1589578228447-e1a4e481c6c8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier law school in India",
        website: "https://www.nls.ac.in/",
        overallRank: 1,
        nirf_rank: 1,
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
      },
      {
        name: "Faculty of Law Delhi University",
        shortName: "DU Law",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1924,
        type: "Government",
        affiliation: "Central University",
        imageUrl: "https://images.unsplash.com/photo-1589578228447-e1a4e481c6c8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Historic law faculty with affordable education",
        website: "https://lawfaculty.du.ac.in/",
        overallRank: 4,
        nirf_rank: 6,
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
      },
      {
        name: "St. Xavier's College Mumbai",
        shortName: "St. Xavier's Mumbai",
        location: "Mumbai, Maharashtra",
        state: "Maharashtra",
        city: "Mumbai",
        establishedYear: 1869,
        type: "Private",
        affiliation: "University of Mumbai",
        imageUrl: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier arts and science college",
        website: "https://www.xaviers.edu/",
        overallRank: 2,
        nirf_rank: 5,
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
      },
      {
        name: "Lady Shri Ram College",
        shortName: "LSR Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1956,
        type: "Government",
        affiliation: "University of Delhi",
        imageUrl: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier women's college for arts and commerce",
        website: "https://www.lsr.edu.in/",
        overallRank: 3,
        nirf_rank: 4,
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
      },
      {
        name: "Indian Agricultural Research Institute",
        shortName: "IARI Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1905,
        type: "Government",
        affiliation: "ICAR",
        imageUrl: "https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier agricultural research institute",
        website: "https://www.iari.res.in/",
        overallRank: 1,
        nirf_rank: 1,
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
      },
      {
        name: "Shri Ram College of Commerce",
        shortName: "SRCC Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1926,
        type: "Government",
        affiliation: "University of Delhi",
        imageUrl: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Top commerce college with excellent placements",
        website: "https://srcc.edu/",
        overallRank: 1,
        nirf_rank: 2,
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
      },
      {
        name: "School of Planning and Architecture",
        shortName: "SPA Delhi",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1941,
        type: "Government",
        affiliation: "Institute of National Importance",
        imageUrl: "https://images.unsplash.com/photo-1503387762-592deb58ef4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier architecture and planning school",
        website: "https://www.spa.ac.in/",
        overallRank: 1,
        nirf_rank: 1,
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
      },
      {
        name: "Jawaharlal Nehru University",
        shortName: "JNU",
        location: "New Delhi, Delhi",
        state: "Delhi",
        city: "New Delhi",
        establishedYear: 1969,
        type: "Government",
        affiliation: "Central University",
        imageUrl: "https://images.unsplash.com/photo-1607237138185-eedd9c632b0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
        description: "Premier university for social sciences and liberal arts",
        website: "https://www.jnu.ac.in/",
        overallRank: 2,
        nirf_rank: 2,
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
      }
    ];

    collegesData.forEach(college => {
      this.createCollege(college);
    });

    // Seed exams
    const examsData: InsertExam[] = [
      {
        name: "JEE Main",
        fullName: "Joint Entrance Examination Main",
        type: "Engineering",
        conductingBody: "National Testing Agency",
        frequency: "Bi-annual",
        eligibility: "12th pass with Physics, Chemistry, Mathematics",
        totalMarks: 300,
        duration: "3 hours",
        website: "https://jeemain.nta.nic.in/",
      },
      {
        name: "JEE Advanced",
        fullName: "Joint Entrance Examination Advanced",
        type: "Engineering",
        conductingBody: "IIT",
        frequency: "Annual",
        eligibility: "JEE Main qualified",
        totalMarks: 372,
        duration: "6 hours (2 papers)",
        website: "https://jeeadv.ac.in/",
      },
      {
        name: "NEET",
        fullName: "National Eligibility cum Entrance Test",
        type: "Medical",
        conductingBody: "National Testing Agency",
        frequency: "Annual",
        eligibility: "12th pass with Physics, Chemistry, Biology",
        totalMarks: 720,
        duration: "3 hours 20 minutes",
        website: "https://neet.nta.nic.in/",
      },
      {
        name: "CAT",
        fullName: "Common Admission Test",
        type: "Management",
        conductingBody: "IIM",
        frequency: "Annual",
        eligibility: "Bachelor's degree with minimum 50% marks",
        totalMarks: 300,
        duration: "3 hours",
        website: "https://iimcat.ac.in/",
      },
      {
        name: "GATE",
        fullName: "Graduate Aptitude Test in Engineering",
        type: "Engineering",
        conductingBody: "IIT/IISc",
        frequency: "Annual",
        eligibility: "Bachelor's degree in Engineering/Science",
        totalMarks: 100,
        duration: "3 hours",
        website: "https://gate.iitr.ac.in/",
      },
      {
        name: "CLAT",
        fullName: "Common Law Admission Test",
        type: "Law",
        conductingBody: "Consortium of NLUs",
        frequency: "Annual",
        eligibility: "12th pass or Bachelor's degree",
        totalMarks: 200,
        duration: "2 hours",
        website: "https://consortiumofnlus.ac.in/",
      },
      {
        name: "BITSAT",
        fullName: "BITS Admission Test",
        type: "Engineering",
        conductingBody: "BITS Pilani",
        frequency: "Annual",
        eligibility: "12th pass with PCM and minimum 75% marks",
        totalMarks: 450,
        duration: "3 hours",
        website: "https://www.bitsadmission.com/",
      },
      {
        name: "VITEEE",
        fullName: "VIT Engineering Entrance Exam",
        type: "Engineering",
        conductingBody: "VIT University",
        frequency: "Annual",
        eligibility: "12th pass with PCM and minimum 60% marks",
        totalMarks: 125,
        duration: "2.5 hours",
        website: "https://viteee.vit.ac.in/",
      },
      {
        name: "XAT",
        fullName: "Xavier Aptitude Test",
        type: "Management",
        conductingBody: "XLRI Jamshedpur",
        frequency: "Annual",
        eligibility: "Bachelor's degree in any discipline",
        totalMarks: 100,
        duration: "3.5 hours",
        website: "https://xatonline.in/",
      },
      {
        name: "MAT",
        fullName: "Management Aptitude Test",
        type: "Management",
        conductingBody: "All India Management Association",
        frequency: "Multiple times a year",
        eligibility: "Bachelor's degree in any discipline",
        totalMarks: 200,
        duration: "2.5 hours",
        website: "https://www.aima.in/",
      },
      {
        name: "CMAT",
        fullName: "Common Management Admission Test",
        type: "Management",
        conductingBody: "National Testing Agency",
        frequency: "Bi-annual",
        eligibility: "Bachelor's degree in any discipline with 50% marks",
        totalMarks: 400,
        duration: "3 hours",
        website: "https://cmat.nta.nic.in/",
      },
      {
        name: "NATA",
        fullName: "National Aptitude Test in Architecture",
        type: "Architecture",
        conductingBody: "Council of Architecture",
        frequency: "Bi-annual",
        eligibility: "12th pass with minimum 50% marks in PCM",
        totalMarks: 200,
        duration: "3 hours",
        website: "https://nata.in/",
      },
      {
        name: "AIIMS MBBS",
        fullName: "AIIMS MBBS Entrance Exam",
        type: "Medical",
        conductingBody: "All India Institute of Medical Sciences",
        frequency: "Annual",
        eligibility: "12th pass with PCB and minimum 60% marks",
        totalMarks: 200,
        duration: "3.5 hours",
        website: "https://www.aiimsexams.ac.in/",
      },
      {
        name: "KVPY",
        fullName: "Kishore Vaigyanik Protsahan Yojana",
        type: "Science",
        conductingBody: "Indian Institute of Science",
        frequency: "Annual",
        eligibility: "11th/12th students with science subjects",
        totalMarks: 100,
        duration: "3 hours",
        website: "http://kvpy.iisc.ernet.in/",
      },
      {
        name: "JIPMER",
        fullName: "Jawaharlal Institute of Postgraduate Medical Education and Research",
        type: "Medical",
        conductingBody: "JIPMER",
        frequency: "Annual",
        eligibility: "12th pass with PCB and minimum 50% marks",
        totalMarks: 200,
        duration: "2.5 hours",
        website: "https://www.jipmer.edu.in/",
      },
      {
        name: "ICAR AIEEA",
        fullName: "All India Entrance Examination for Admission",
        type: "Agriculture",
        conductingBody: "Indian Council of Agricultural Research",
        frequency: "Annual",
        eligibility: "12th pass with PCB/PCM and minimum 50% marks",
        totalMarks: 600,
        duration: "3 hours",
        website: "https://icar.nta.nic.in/",
      },
      {
        name: "GPAT",
        fullName: "Graduate Pharmacy Aptitude Test",
        type: "Pharmacy",
        conductingBody: "National Testing Agency",
        frequency: "Annual",
        eligibility: "B.Pharm degree or equivalent",
        totalMarks: 500,
        duration: "3 hours",
        website: "https://gpat.nta.nic.in/",
      }
    ];

    examsData.forEach(exam => {
      this.createExam(exam);
    });
  }

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
    let results = Array.from(this.colleges.values());

    if (filters?.search) {
      const searchLower = filters.search.toLowerCase();
      results = results.filter(college => 
        college.name.toLowerCase().includes(searchLower) ||
        college.shortName?.toLowerCase().includes(searchLower) ||
        college.location.toLowerCase().includes(searchLower)
      );
    }

    if (filters?.state) {
      results = results.filter(college => college.state === filters.state);
    }

    if (filters?.location) {
      results = results.filter(college => 
        college.location.toLowerCase().includes(filters.location!.toLowerCase())
      );
    }

    if (filters?.minFees !== undefined) {
      results = results.filter(college => 
        parseFloat(college.fees || "0") >= filters.minFees!
      );
    }

    if (filters?.maxFees !== undefined) {
      results = results.filter(college => 
        parseFloat(college.fees || "0") <= filters.maxFees!
      );
    }

    // Sort by rank
    results.sort((a, b) => (a.overallRank || 999) - (b.overallRank || 999));

    if (filters?.offset) {
      results = results.slice(filters.offset);
    }

    if (filters?.limit) {
      results = results.slice(0, filters.limit);
    }

    return results;
  }

  async getCollege(id: number): Promise<College | undefined> {
    return this.colleges.get(id);
  }

  async createCollege(insertCollege: InsertCollege): Promise<College> {
    const id = this.currentCollegeId++;
    const college: College = { 
      ...insertCollege,
      shortName: insertCollege.shortName || null,
      establishedYear: insertCollege.establishedYear || null,
      affiliation: insertCollege.affiliation || null,
      imageUrl: insertCollege.imageUrl || null,
      description: insertCollege.description || null,
      website: insertCollege.website || null,
      overallRank: insertCollege.overallRank || null,
      nirf_rank: insertCollege.nirf_rank || null,
      fees: insertCollege.fees || null,
      feesPeriod: insertCollege.feesPeriod || "yearly",
      rating: insertCollege.rating || null,
      reviewCount: insertCollege.reviewCount || 0,
      admissionProcess: insertCollege.admissionProcess || null,
      cutoffScore: insertCollege.cutoffScore || null,
      placementRate: insertCollege.placementRate || null,
      averagePackage: insertCollege.averagePackage || null,
      highestPackage: insertCollege.highestPackage || null,
      hostelFees: insertCollege.hostelFees || null,
      hasHostel: insertCollege.hasHostel || false,
      id,
      createdAt: new Date()
    };
    this.colleges.set(id, college);
    return college;
  }

  async getCoursesByCollege(collegeId: number): Promise<Course[]> {
    return Array.from(this.courses.values()).filter(
      course => course.collegeId === collegeId
    );
  }

  async getCourse(id: number): Promise<Course | undefined> {
    return this.courses.get(id);
  }

  async getExams(): Promise<Exam[]> {
    return Array.from(this.exams.values());
  }

  async getExam(id: number): Promise<Exam | undefined> {
    return this.exams.get(id);
  }

  async createExam(insertExam: InsertExam): Promise<Exam> {
    const id = this.currentExamId++;
    const exam: Exam = {
      ...insertExam,
      fullName: insertExam.fullName || null,
      conductingBody: insertExam.conductingBody || null,
      frequency: insertExam.frequency || null,
      applicationStartDate: insertExam.applicationStartDate || null,
      applicationEndDate: insertExam.applicationEndDate || null,
      examDate: insertExam.examDate || null,
      resultDate: insertExam.resultDate || null,
      eligibility: insertExam.eligibility || null,
      syllabus: insertExam.syllabus || null,
      examPattern: insertExam.examPattern || null,
      totalMarks: insertExam.totalMarks || null,
      duration: insertExam.duration || null,
      website: insertExam.website || null,
      id,
      createdAt: new Date()
    };
    this.exams.set(id, exam);
    return exam;
  }

  async getReviewsByCollege(collegeId: number): Promise<Review[]> {
    return Array.from(this.reviews.values()).filter(
      review => review.collegeId === collegeId
    );
  }

  async createReview(insertReview: InsertReview): Promise<Review> {
    const id = this.currentReviewId++;
    const review: Review = {
      ...insertReview,
      collegeId: insertReview.collegeId || null,
      studentName: insertReview.studentName || null,
      course: insertReview.course || null,
      graduationYear: insertReview.graduationYear || null,
      rating: insertReview.rating || null,
      title: insertReview.title || null,
      content: insertReview.content || null,
      likes: insertReview.likes || 0,
      verified: insertReview.verified || false,
      id,
      createdAt: new Date()
    };
    this.reviews.set(id, review);
    return review;
  }

  async getComparison(id: number): Promise<Comparison | undefined> {
    return this.comparisons.get(id);
  }

  async createComparison(insertComparison: InsertComparison): Promise<Comparison> {
    const id = this.currentComparisonId++;
    const comparison: Comparison = {
      ...insertComparison,
      name: insertComparison.name || null,
      collegeIds: Array.isArray(insertComparison.collegeIds) ? (insertComparison.collegeIds as number[]) : null,
      userId: insertComparison.userId || null,
      id,
      createdAt: new Date()
    };
    this.comparisons.set(id, comparison);
    return comparison;
  }

  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      user => user.username === username
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.currentUserId++;
    const user: User = { 
      ...insertUser,
      preferences: insertUser.preferences && typeof insertUser.preferences === 'object' ? insertUser.preferences as {
        interestedCourses?: string[];
        preferredLocations?: string[];
        budgetRange?: { min: number; max: number };
      } : null,
      id,
      createdAt: new Date()
    };
    this.users.set(id, user);
    return user;
  }
}

export const storage = new MemStorage();
