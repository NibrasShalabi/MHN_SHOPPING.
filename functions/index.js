const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setGenderClaim = onDocumentCreated("users/{uid}", async (event) => {
  const uid = event.params.uid;
  const data = event.data.data();

  if (data.isFemale === true) {
    await admin.auth().setCustomUserClaims(uid, { gender: "female" });
  }
});
exports.incrementUserCount = onDocumentCreated("users/{uid}", async (event) => {
  const db = admin.firestore();
  const statsRef = db.collection("config").doc("stats");

  await statsRef.set(
    { totalUsers: admin.firestore.FieldValue.increment(1) },
    { merge: true }
  );
});