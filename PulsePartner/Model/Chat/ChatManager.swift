//
//  ChatManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 06.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import Firebase

class ChatManager {
    static let sharedInstance = ChatManager()
    let fStore: Firestore
    let fStorage: Storage
    
    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }
    
    func fetchMessages() {
        fStore.collection("users").document(UserManager.sharedInstance.auth.currentUser!.uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("ERROR!: \(error.debugDescription)")
                    return
                }
                guard let data = document.data() else {
                    print("Document was empty")
                    return
                }
                print("DATA: \(data)")
        }
    }
}
