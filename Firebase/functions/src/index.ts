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


interface MatchData {
  username: string
  image: string
  age: number
  weight: number
  fitnessLevel: number
  gender: string
  preferences: string[]
  heartrate: number
  location: admin.firestore.GeoPoint
  timestamp: admin.firestore.Timestamp
}

interface Match {
  username: string
  age: number
  image: string
  gender: string
}

function extract<T>(properties: Record<keyof T, true>){
  return function<TActual extends T>(value: TActual){
      const result = {} as T;
      for (const property of Object.keys(properties) as Array<keyof T>) {
          result[property] = value[property];
      }
      return result;
  }
}

const extractMatch = extract<Match>({ 
  // This object literal is guaranteed by the compiler to have no more and no less properties then ISpecific
  username: true, age: true, image: true, gender: true
})

function calculateDistance(lat1: number, lat2: number, long1: number, long2: number) {
  const p = 0.017453292519943295;   // Math.PI / 180
  const a = 0.5 - Math.cos((lat1-lat2) * p) / 2 + Math.cos(lat2 * p) *Math.cos((lat1) * p) * (1 - Math.cos(((long1- long2) * p))) / 2;
  const distance = (12742 * Math.asin(Math.sqrt(a)));   // 2 * R; R = 6371 km
  return distance;
}

function doMatch(userA: admin.firestore.QueryDocumentSnapshot, userB: admin.firestore.QueryDocumentSnapshot): Boolean {
  const dataA: MatchData = userA.data() as MatchData
  const dataB: MatchData = userB.data() as MatchData

  if (!dataB.preferences.includes(dataA.gender) || !dataA.preferences.includes(dataB.gender)) {
    return false
  }

  if (Math.abs(dataA.heartrate-dataB.heartrate) > 5) {
    return false
  }

  const distance = calculateDistance(dataA.location.latitude, dataB.location.latitude, dataA.location.longitude, dataB.location.longitude)
  console.log("Distanze: " + distance + "km")
  if (distance > 0.3) {
    return false
  }

  return true
}

async function createMatch(userA: admin.firestore.QueryDocumentSnapshot, userB: admin.firestore.QueryDocumentSnapshot) {
  const dataA: Match = extractMatch(userA.data() as MatchData)
  const dataB: Match = extractMatch(userB.data() as MatchData)

  try {
    const refA = firebase.firestore().collection("users").doc(userA.id).collection("matches").doc(userB.id)
    await refA.create(dataB)
    
    const refB = firebase.firestore().collection("users").doc(userB.id).collection("matches").doc(userA.id)
    await refB.create(dataA)
  } catch (err) {
    console.log("Already matched.")
  }
  
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
    
    docs.forEach(async (doc, index, array) => {
      for (let i = index + 1; i < docs.length; i++) {
        if (doMatch(doc, docs[i])) {
          console.log("Match!")
          await createMatch(doc, docs[i])
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
