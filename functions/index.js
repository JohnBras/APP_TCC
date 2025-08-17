// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();
// const db = admin.firestore();

// exports.predictDemand = functions.https.onCall(async (data) => {
//   const { productId, weeksAhead } = data;
//   const doc = await db.collection("forecasts").doc(productId).get();
//   if (!doc.exists) throw new functions.https.HttpsError("not-found", "Forecast not found");
//   const { slope, intercept } = doc.data().coefficients;
//   const trainedAt = doc.data().trainedAt.toDate();
//   const nowWeeks = Date.now()/1000/(7*24*3600);
//   const trainedWeeks = trainedAt.getTime()/1000/(7*24*3600);
//   const x = trainedWeeks + weeksAhead;
//   const forecast = slope * x + intercept;
//   return { forecast: Math.max(0, Math.round(forecast)) };
// });
