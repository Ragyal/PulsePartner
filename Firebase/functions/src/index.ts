import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const firebase = admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

export const matchUsers = functions
  .region("europe-west1")
  .pubsub
  .topic("matchUsers")
  .onPublish(async message => {
    console.log("Matching invoked...")
    return;
  });

export const removeUser = functions
  .region("europe-west1")
  .auth.user()
  .onDelete(async (user) => {
    const bucket = firebase.storage().bucket();
  
    const asyncUserImageDeletion = bucket.deleteFiles({ prefix: `profilePictures/${user.uid}.png` });
    const asyncUserDocDeletion = firebase.firestore().doc(`users/${user.uid}`).delete()
  
    return Promise.all([asyncUserDocDeletion, asyncUserImageDeletion])
  });
