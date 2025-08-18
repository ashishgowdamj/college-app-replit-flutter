import admin from 'firebase-admin';
import fs from 'fs';

// Initialize Firebase Admin SDK
const serviceAccount = JSON.parse(fs.readFileSync('./serviceAccountKey.json', 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://college-comp.firebaseio.com",
  storageBucket: "college-comp.firebasestorage.app"
});

const db = admin.firestore();

// Helper: map incoming snake_case data to app's expected camelCase schema
function mapToAppSchema(src) {
  const mapped = {
    name: src.name,
    shortName: src.short_name,
    location: src.location,
    state: src.state,
    city: src.city,
    establishedYear: src.established_year,
    type: src.type,
    affiliation: src.affiliation,
    imageUrl: src.image_url,
    description: src.description,
    website: src.website,
    overallRank: src.overall_rank,
    nirfRank: src.nirf_rank,
    // Keep fees as string for compatibility with current Flutter filters
    fees: src.fees,
    feesPeriod: src.fees_period,
    rating: src.rating,
    reviewCount: src.review_count,
    admissionProcess: src.admission_process,
    cutoffScore: src.cutoff_score,
    placementRate: src.placement_rate,
    averagePackage: src.average_package,
    highestPackage: src.highest_package,
    hostelFees: src.hostel_fees,
    hasHostel: src.has_hostel,
    createdAt: src.created_at,
    // Optional passthroughs if present in data
    contact: src.contact,
    courses_offered: src.courses_offered,
    placements: src.placements,
    facilities: src.facilities,
    images: src.images,
    brochures: src.brochures,
    tags: src.tags,
    category: src.category,
  };

  // Remove undefined fields to keep Firestore clean
  Object.keys(mapped).forEach((k) => mapped[k] === undefined && delete mapped[k]);
  return mapped;
}

// College data from the JSON file you provided
const collegesData = [
  {
    "name": "Indian Institute of Technology Delhi",
    "short_name": "IIT Delhi",
    "location": "New Delhi, Delhi",
    "state": "Delhi",
    "city": "New Delhi",
    "established_year": 1961,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier engineering and technology institute",
    "website": "https://home.iitd.ac.in/",
    "overall_rank": 1,
    "nirf_rank": 2,
    "fees": "250000",
    "fees_period": "yearly",
    "rating": "4.5",
    "review_count": 2100,
    "admission_process": "JEE Advanced",
    "cutoff_score": 99,
    "placement_rate": "95.5",
    "average_package": "1800000",
    "highest_package": "5000000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "All India Institute of Medical Sciences",
    "short_name": "AIIMS Delhi",
    "location": "New Delhi, Delhi",
    "state": "Delhi",
    "city": "New Delhi",
    "established_year": 1956,
    "type": "Government",
    "affiliation": "Ministry of Health and Family Welfare",
    "image_url": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier medical college and hospital",
    "website": "https://www.aiims.edu/",
    "overall_rank": 1,
    "nirf_rank": 1,
    "fees": "130000",
    "fees_period": "yearly",
    "rating": "4.8",
    "review_count": 1800,
    "admission_process": "NEET",
    "cutoff_score": 98,
    "placement_rate": "100",
    "average_package": "1200000",
    "highest_package": "2500000",
    "hostel_fees": "15000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Management Ahmedabad",
    "short_name": "IIM Ahmedabad",
    "location": "Ahmedabad, Gujarat",
    "state": "Gujarat",
    "city": "Ahmedabad",
    "established_year": 1961,
    "type": "Government",
    "affiliation": "IIM System",
    "image_url": "https://images.unsplash.com/photo-1523050854058-8df90110c9e1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier business school",
    "website": "https://www.iima.ac.in/",
    "overall_rank": 1,
    "nirf_rank": 1,
    "fees": "2300000",
    "fees_period": "total",
    "rating": "4.7",
    "review_count": 1200,
    "admission_process": "CAT",
    "cutoff_score": 99,
    "placement_rate": "100",
    "average_package": "2500000",
    "highest_package": "6000000",
    "hostel_fees": "35000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Jawaharlal Nehru University",
    "short_name": "JNU",
    "location": "New Delhi, Delhi",
    "state": "Delhi",
    "city": "New Delhi",
    "established_year": 1969,
    "type": "Government",
    "affiliation": "Central University",
    "image_url": "https://images.unsplash.com/photo-1607237138185-eedd9c632b0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier university for social sciences and liberal arts",
    "website": "https://www.jnu.ac.in/",
    "overall_rank": 2,
    "nirf_rank": 2,
    "fees": "25000",
    "fees_period": "yearly",
    "rating": "4.3",
    "review_count": 1500,
    "admission_process": "JNU Entrance Exam",
    "cutoff_score": 85,
    "placement_rate": "75",
    "average_package": "800000",
    "highest_package": "1500000",
    "hostel_fees": "12000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Delhi University",
    "short_name": "DU",
    "location": "New Delhi, Delhi",
    "state": "Delhi",
    "city": "New Delhi",
    "established_year": 1922,
    "type": "Government",
    "affiliation": "Central University",
    "image_url": "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier university with diverse academic programs",
    "website": "https://www.du.ac.in/",
    "overall_rank": 3,
    "nirf_rank": 3,
    "fees": "15000",
    "fees_period": "yearly",
    "rating": "4.2",
    "review_count": 2800,
    "admission_process": "CUET",
    "cutoff_score": 90,
    "placement_rate": "70",
    "average_package": "600000",
    "highest_package": "1200000",
    "hostel_fees": "10000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Technology Bombay",
    "short_name": "IIT Bombay",
    "location": "Mumbai, Maharashtra",
    "state": "Maharashtra",
    "city": "Mumbai",
    "established_year": 1958,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier engineering and technology institute",
    "website": "https://www.iitb.ac.in/",
    "overall_rank": 2,
    "nirf_rank": 3,
    "fees": "250000",
    "fees_period": "yearly",
    "rating": "4.6",
    "review_count": 1900,
    "admission_process": "JEE Advanced",
    "cutoff_score": 98,
    "placement_rate": "96",
    "average_package": "1700000",
    "highest_package": "4800000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Technology Madras",
    "short_name": "IITM",
    "location": "Chennai, Tamil Nadu",
    "state": "Tamil Nadu",
    "city": "Chennai",
    "established_year": 1959,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "IIT Madras is India's #1 engineering institute, renowned for its academic excellence, cutting-edge research, and high placement rates across top global recruiters.",
    "website": "https://www.iitm.ac.in/",
    "overall_rank": 1,
    "nirf_rank": 1,
    "nirf_score": 89.79,
    "fees": "242000",
    "fees_period": "yearly",
    "rating": "4.8",
    "review_count": 1800,
    "admission_process": "JEE Advanced",
    "cutoff_score": 99,
    "placement_rate": "95.8",
    "average_package": "2120000",
    "highest_package": "5000000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "contact": {
      "address": "Indian Institute of Technology Madras, IIT P.O., Chennai, Tamil Nadu 600036",
      "phone": "+91 44 2257 8101",
      "email": "registrar@iitm.ac.in",
      "website": "https://www.iitm.ac.in",
      "googleMapsUrl": "https://goo.gl/maps/N9B5iZ3hYxP2"
    },
    "courses_offered": [
      {
        "name": "B.Tech",
        "duration": "4 years",
        "seatIntake": 1132,
        "specializations": [
          "Aerospace Engineering",
          "Biological Engineering",
          "Chemical Engineering",
          "Civil Engineering",
          "Computer Science and Engineering",
          "Electrical Engineering",
          "Engineering Physics",
          "Mechanical Engineering",
          "Metallurgical and Materials Engineering",
          "Naval Architecture and Ocean Engineering"
        ],
        "cutoffRanks": [
          {
            "branch": "Computer Science and Engineering",
            "exam": "JEE Advanced",
            "year": 2024,
            "general": 172,
            "obc": 87,
            "sc": 43,
            "st": 28,
            "ews": 29
          },
          {
            "branch": "Electrical Engineering",
            "exam": "JEE Advanced",
            "year": 2024,
            "general": 801,
            "obc": 382,
            "sc": 208,
            "st": 103,
            "ews": 141
          },
          {
            "branch": "Mechanical Engineering",
            "exam": "JEE Advanced",
            "year": 2024,
            "general": 2490,
            "obc": 1230,
            "sc": 563,
            "st": 300,
            "ews": 420
          }
        ]
      }
    ],
    "placements": {
      "placementPercentage": 95.8,
      "avgPackage": 2120000,
      "highestPackage": 5000000,
      "topRecruiters": ["Google", "Microsoft", "Amazon", "Tata Consultancy Services", "Qualcomm", "Texas Instruments"],
      "lastPlacementDrive": "2024-25"
    },
    "facilities": [
      "Central Library",
      "Hostels",
      "Sports Complex",
      "Research Labs",
      "Wi‑Fi Campus",
      "Innovation & Incubation Centre"
    ],
    "images": [
      {
        "type": "logo",
        "url": "https://upload.wikimedia.org/wikipedia/en/6/69/IIT_Madras_Logo.svg"
      },
      {
        "type": "campus",
        "url": "https://www.iitm.ac.in/sites/default/files/styles/hero_image/public/2022-02/iitm-campus.jpg"
      }
    ],
    "brochures": [
      {
        "type": "placementReport",
        "url": "https://www.iitm.ac.in/sites/default/files/placements/Placement_Report_2024.pdf"
      },
      {
        "type": "courseCatalog",
        "url": "https://www.iitm.ac.in/sites/default/files/courses/Course_Catalog_2024.pdf"
      }
    ],
    "tags": ["Top IIT", "AICTE Approved", "South India"],
    "category": "IIT",
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Technology Kanpur",
    "short_name": "IIT Kanpur",
    "location": "Kanpur, Uttar Pradesh",
    "state": "Uttar Pradesh",
    "city": "Kanpur",
    "established_year": 1959,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier engineering and technology institute",
    "website": "https://www.iitk.ac.in/",
    "overall_rank": 4,
    "nirf_rank": 4,
    "fees": "250000",
    "fees_period": "yearly",
    "rating": "4.4",
    "review_count": 1700,
    "admission_process": "JEE Advanced",
    "cutoff_score": 96,
    "placement_rate": "94",
    "average_package": "1500000",
    "highest_package": "4200000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Technology Kharagpur",
    "short_name": "IIT Kharagpur",
    "location": "Kharagpur, West Bengal",
    "state": "West Bengal",
    "city": "Kharagpur",
    "established_year": 1951,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier engineering and technology institute",
    "website": "https://www.iitkgp.ac.in/",
    "overall_rank": 5,
    "nirf_rank": 5,
    "fees": "250000",
    "fees_period": "yearly",
    "rating": "4.3",
    "review_count": 1600,
    "admission_process": "JEE Advanced",
    "cutoff_score": 95,
    "placement_rate": "93",
    "average_package": "1400000",
    "highest_package": "4000000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  },
  {
    "name": "Indian Institute of Technology Roorkee",
    "short_name": "IIT Roorkee",
    "location": "Roorkee, Uttarakhand",
    "state": "Uttarakhand",
    "city": "Roorkee",
    "established_year": 1847,
    "type": "Government",
    "affiliation": "IIT System",
    "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=200",
    "description": "Premier engineering and technology institute",
    "website": "https://www.iitr.ac.in/",
    "overall_rank": 6,
    "nirf_rank": 6,
    "fees": "250000",
    "fees_period": "yearly",
    "rating": "4.2",
    "review_count": 1500,
    "admission_process": "JEE Advanced",
    "cutoff_score": 94,
    "placement_rate": "92",
    "average_package": "1300000",
    "highest_package": "3800000",
    "hostel_fees": "25000",
    "has_hostel": true,
    "created_at": new Date().toISOString()
  }
];

async function importColleges() {
  try {
    console.log('Starting college import process...');
    
    // Get existing colleges to check for duplicates
    const existingCollegesSnapshot = await db.collection('colleges').get();
    const existingCollegeNames = new Set();
    
    existingCollegesSnapshot.forEach(doc => {
      const data = doc.data();
      existingCollegeNames.add(data.name.toLowerCase().trim());
    });
    
    console.log(`Found ${existingCollegeNames.size} existing colleges in Firestore`);
    
    let importedCount = 0;
    let skippedCount = 0;
    
    for (const collegeData of collegesData) {
      const collegeName = collegeData.name.toLowerCase().trim();
      
      if (existingCollegeNames.has(collegeName)) {
        console.log(`Skipping duplicate: ${collegeData.name}`);
        skippedCount++;
        continue;
      }
      
      try {
        // Map to app schema and add the college to Firestore
        const payload = mapToAppSchema({
          ...collegeData,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });

        const docRef = await db.collection('colleges').add(payload);

        console.log(`✓ Imported: ${collegeData.name} with ID: ${docRef.id}`);
        importedCount++;
        
        // Add to existing set to prevent duplicates within the same import
        existingCollegeNames.add(collegeName);
        
      } catch (error) {
        console.error(`✗ Error importing ${collegeData.name}:`, error.message);
      }
    }
    
    console.log('\n=== Import Summary ===');
    console.log(`Total colleges in data: ${collegesData.length}`);
    console.log(`Successfully imported: ${importedCount}`);
    console.log(`Skipped (duplicates): ${skippedCount}`);
    console.log('Import process completed!');
    
  } catch (error) {
    console.error('Error during import:', error);
  } finally {
    process.exit(0);
  }
}

// Run the import
importColleges(); 