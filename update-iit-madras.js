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

// Updated IIT Madras data
const updatedIITMadrasData = {
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
  "updated_at": new Date().toISOString()
};

async function updateIITMadras() {
  try {
    console.log('Starting IIT Madras update process...');
    
    // Find the existing IIT Madras document
    const collegesRef = db.collection('colleges');
    const query = collegesRef.where('name', '==', 'Indian Institute of Technology Madras');
    const snapshot = await query.get();
    
    if (snapshot.empty) {
      console.log('❌ IIT Madras not found in database');
      return;
    }
    
    // Update the first matching document
    const doc = snapshot.docs[0];
    await doc.ref.update({
      ...updatedIITMadrasData,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ Successfully updated IIT Madras with ID: ${doc.id}`);
    console.log('Updated fields:');
    console.log('- Rating: 4.5 → 4.8');
    console.log('- NIRF Rank: #1 (with score 89.79)');
    console.log('- Fees: ₹250K → ₹242K');
    console.log('- Placement Rate: 95% → 95.8%');
    console.log('- Average Package: ₹16 LPA → ₹21.2 LPA');
    console.log('- Highest Package: ₹45 LPA → ₹50 LPA');
    console.log('- Added comprehensive course details');
    console.log('- Added contact information');
    console.log('- Added facilities list');
    console.log('- Added placement details with top recruiters');
    console.log('- Added images and brochures');
    
  } catch (error) {
    console.error('❌ Error updating IIT Madras:', error);
  } finally {
    process.exit(0);
  }
}

// Run the update
updateIITMadras(); 