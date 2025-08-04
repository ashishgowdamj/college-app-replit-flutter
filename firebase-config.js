// Firebase configuration for Campus Connect App
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://campus-connect-app.firebaseio.com",
  storageBucket: "campus-connect-app.appspot.com"
});

// Get Firestore database
const db = admin.firestore();

// Get Authentication
const auth = admin.auth();

// Get Storage
const storage = admin.storage();

module.exports = {
  admin,
  db,
  auth,
  storage
}; 