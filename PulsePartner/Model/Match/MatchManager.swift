//
//  MatchManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 17.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import Firebase

class MatchManager {

    static let sharedInstance = MatchManager()
    let fStore: Firestore
    let fStorage: Storage
    var allMatches = [User]()

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }

    func loadMatches(completion: @escaping ([User]) -> Void) {
        fStore.collection("users").getDocuments { snapshot, error in
            print(error ?? "No error.")
            self.allMatches = []
            guard let snapshot = snapshot else {
                completion(self.allMatches)
                return
            }
            for doc in snapshot.documents {
                let url = (doc.get("profile_picture") as? String)!
                UserManager.sharedInstance.getProfilePicture(url: url) { file in
                    let userID = doc.documentID
                    let selfID = UserManager.sharedInstance.auth.currentUser!.uid
                    guard let image = doc.get("profile_picture") as? String else {
                        return
                    }

                    guard let name = doc.get("username") as? String else {
                        return
                    }

                    guard let age = doc.get("age") as? Int else {
                        return
                    }

                    guard let weight = doc.get("weight") as? Int else {
                        return
                    }
                    print("UserID: \(userID)")
                    if selfID != userID {
                        let user = User(userID: userID,
                                        image: image,
                                        name: name,
                                        age: age,
                                        bpm: 95,
                                        weight: weight,
                                        profilePicture: file)
                        self.allMatches.append(user)
                        self.fStore.collection("users").document(selfID).collection("matches").document(userID).setData([
                            "username": name,
                            "profile_picture": url
                            ])
                    }
                    if self.allMatches.count == snapshot.documents.count-1 {
                        completion(self.allMatches)
                    }
                }
            }
        }
    }
}
