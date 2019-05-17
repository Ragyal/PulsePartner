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

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }

    func getMatches() {
        var allMatches = [User]()
        fStore.collection("users").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                for document in querySnapshot!.documents {
                    allMatches.append(User(userID: 0,
                                           image: "ProfilePicture",
                                           name: document.get("username")! as! String,
                                           age: document.get("age")! as! Int,
                                           bpm: document.get("weight")! as! Int))
                }
                MainViewController.sharedInstance.allMatches = allMatches
            }
        }
    }
}
