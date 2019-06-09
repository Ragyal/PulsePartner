import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const firebase = admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

export const removeMatchData = functions
.region("europe-west1")
.pubsub
.topic("removeOldData")
.onPublish(async message => {
  console.log("Garbage collection invoked...")

  const now = admin.firestore.Timestamp.now()
  const threshold = new admin.firestore.Timestamp(now.seconds - (5*60), 0)

  return firebase.firestore().collection("matchData").where("timestamp", "<=", threshold).get().then(querySnapshot => {
    querySnapshot.forEach(async doc => {
      console.log(doc.id)
      await doc.ref.delete()
    })
  })
});


function doMatch(userA: admin.firestore.QueryDocumentSnapshot, userB: admin.firestore.QueryDocumentSnapshot): Boolean {
  return true
}

export const matchUsers = functions
.region("europe-west1")
.pubsub
.topic("matchUsers")
.onPublish(async message => {
  console.log("Matching invoked...")
  
  return firebase.firestore().collection("matchData").get().then(querySnapshot => {
    const docs: admin.firestore.QueryDocumentSnapshot[] = []
    
    querySnapshot.forEach(docSnapshot => {
      docs.push(docSnapshot)
    })
    
    docs.forEach((doc, index, array) => {
      for (let i = index + 1; i < docs.length; i++) {
        if (doMatch(doc, docs[i])) {
          console.log("Match!")
        }
      }
    })
  })
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
