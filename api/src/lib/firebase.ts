import admin from "firebase-admin";

// Initialize Firebase Admin SDK
// Expects FIREBASE_SERVICE_ACCOUNT_JSON environment variable
// This should be a JSON string of the service account credentials

let firebaseApp: admin.app.App;

try {
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  
  if (!serviceAccountJson) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT_JSON environment variable is not set. " +
      "Please add your Firebase service account JSON as an environment variable in Render."
    );
  }

  const serviceAccount = JSON.parse(serviceAccountJson);
  
  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  
  console.log("Firebase Admin initialized successfully");
} catch (error: any) {
  console.error("Failed to initialize Firebase Admin:", error.message);
  // Don't throw - allow app to start but auth will fail
  // This is useful for development when Firebase might not be configured yet
}

export { firebaseApp };
export const auth = admin.auth();

