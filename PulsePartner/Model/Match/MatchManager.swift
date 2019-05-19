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
                completion([User]())
                return
            }
            for doc in snapshot.documents {
                let user = User(userID: 0,
                                image: "ProfilePicture",
                                name: doc.get("username")! as! String,
                                age: doc.get("age")! as! Int,
                                bpm: doc.get("weight")! as! Int)
                self.allMatches.append(user)
            }
            completion(self.allMatches)
        }
    }
}
