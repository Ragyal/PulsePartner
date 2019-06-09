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
                UserManager.sharedInstance.getProfilePicture(url: (doc.get("image") as? String)!) { file in
                    guard let image = doc.get("image") as? String else {
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

                    let user = User(userID: 0,
                                    image: image,
                                    name: name,
                                    age: age,
                                    bpm: 95,
                                    weight: weight,
                                    profilePicture: file)
                    self.allMatches.append(user)
                    if self.allMatches.count == snapshot.documents.count {
                        completion(self.allMatches)
                    }
                }
            }
        }
    }
}
