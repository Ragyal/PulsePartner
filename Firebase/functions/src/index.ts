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
  .pubsub.topic("removeOldData")
  .onPublish(async message => {
    console.log("Garbage collection invoked...");

    const now = admin.firestore.Timestamp.now();
    const threshold = new admin.firestore.Timestamp(now.seconds - 5 * 60, 0);

    return firebase
      .firestore()
      .collection("matchData")
      .where("timestamp", "<=", threshold)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(async doc => {
          console.log(doc.id);
          await doc.ref.delete();
        });
      });
  });

interface MatchData {
  username: string;
  image: string;
  age: number;
  weight: number;
  fitnessLevel: number;
  gender: string;
  preferences: string[];
  fcmToken?: string;
  heartrate: number;
  location: admin.firestore.GeoPoint;
  timestamp: admin.firestore.Timestamp;
}

interface Match {
  username: string;
  age: number;
  image: string;
  gender: string;
}

const extract = <T>(
  properties: Record<keyof T, true>,
): (<TActual extends T>(value: TActual) => T) => {
  return <TActual extends T>(value: TActual) => {
    const result = {} as T;
    for (const property of Object.keys(properties) as Array<keyof T>) {
      result[property] = value[property];
    }
    return result;
  };
};

const extractMatch = extract<Match>({
  // This object literal is guaranteed by the compiler to have no more and no less properties then ISpecific
  age: true,
  gender: true,
  image: true,
  username: true,
});

const calculateDistance = (
  lat1: number,
  lat2: number,
  long1: number,
  long2: number,
): number => {
  const p = 0.017453292519943295; // Math.PI / 180
  const a =
    0.5 -
    Math.cos((lat1 - lat2) * p) / 2 +
    (Math.cos(lat2 * p) *
      Math.cos(lat1 * p) *
      (1 - Math.cos((long1 - long2) * p))) /
      2;
  const distance = 12742 * Math.asin(Math.sqrt(a)); // 2 * R; R = 6371 km
  return distance;
};

const doMatch = (
  userA: MatchData,
  userB: MatchData,
): Boolean => {
  if (
    !userB.preferences.includes(userA.gender) ||
    !userA.preferences.includes(userB.gender)
  ) {
    return false;
  }

  if (Math.abs(userA.heartrate - userB.heartrate) > 5) {
    return false;
  }

  const distance = calculateDistance(
    userA.location.latitude,
    userB.location.latitude,
    userA.location.longitude,
    userB.location.longitude,
  );
  console.log("Distanze: " + distance + "km");
  if (distance > 0.3) {
    return false;
  }

  return true;
};

const createMatch = async (
  idA: string,
  userA: MatchData,
  idB: string,
  userB: MatchData,
): Promise<void> => {
  const dataA: Match = extractMatch(userA);
  const dataB: Match = extractMatch(userB);

  try {
    const refA = firebase
      .firestore()
      .collection("users")
      .doc(idA)
      .collection("matches")
      .doc(idA);
    await refA.create(dataB);

    if (userA.fcmToken) {
      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: "Match!",
          body: `${userB.username} (${userB.gender}, ${userB.age}) ist ganz in deiner Nähe.`
        }
      }
      await admin.messaging().sendToDevice(userA.fcmToken, payload)
    }

    const refB = firebase
      .firestore()
      .collection("users")
      .doc(idB)
      .collection("matches")
      .doc(idA);
    await refB.create(dataA);

    if (userB.fcmToken) {
      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: "Match!",
          body: `${userA.username} (${userA.gender}, ${userA.age}) ist ganz in deiner Nähe.`
        }
      }
      await admin.messaging().sendToDevice(userB.fcmToken, payload)
    }
  } catch (err) {
    console.log("Already matched.");
  }
};

export const matchUsers = functions
  .region("europe-west1")
  .pubsub.topic("matchUsers")
  .onPublish(async message => {
    console.log("Matching invoked...");

    return firebase
      .firestore()
      .collection("matchData")
      .get()
      .then(querySnapshot => {
        const docs: admin.firestore.QueryDocumentSnapshot[] = [];

        querySnapshot.forEach(docSnapshot => {
          docs.push(docSnapshot);
        });

        docs.forEach(async (doc, index, array) => {
          for (let i = index + 1; i < docs.length; i++) {
            const userDataA: MatchData = doc.data() as MatchData;
            const userDataB: MatchData = docs[i].data() as MatchData;

            if (doMatch(userDataA, userDataB)) {
              console.log("Match!");
              await createMatch(doc.id, userDataA, docs[i].id, userDataB);
            }
          }
        });
      });
  });

export const removeUser = functions
  .region("europe-west1")
  .auth.user()
  .onDelete(async user => {
    const bucket = firebase.storage().bucket();

    const asyncUserImageDeletion = bucket.deleteFiles({
      prefix: `profilePictures/${user.uid}.png`,
    });
    const asyncUserDocDeletion = firebase
      .firestore()
      .doc(`users/${user.uid}`)
      .delete();

    return Promise.all([asyncUserDocDeletion, asyncUserImageDeletion]);
  });
