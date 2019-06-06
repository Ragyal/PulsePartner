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
    
    func fetchMessages(userID: String, view: ChatViewController) {

//        , "owner", isEqualTo: userID
        fStore.collection("users").document(UserManager.sharedInstance.auth.currentUser!.uid).collection("matches").document(userID).collection("chat").whereField("type", isEqualTo: "message")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("ERROR!: \(error.debugDescription)")
                    return
                }
                let messages = documents.map{ $0["message"]! }
                view.messageBox.text? = ""
                for message in messages {
                    view.messageBox.text? = view.messageBox.text! + "\((message as? String)!)\n"
                }
                
                
        }
    }
    
    func sendMessage(receiver: String, message: String) {
        fStore.collection("users").document(receiver).collection("matches").document(UserManager.sharedInstance.auth.currentUser!.uid).collection("chat").document("\(NSDate.timeIntervalSinceReferenceDate)").setData([
            "type": "message",
            "message": message,
            "owner": UserManager.sharedInstance.auth.currentUser!.uid
            ])
         fStore.collection("users").document(UserManager.sharedInstance.auth.currentUser!.uid).collection("matches").document(receiver).collection("chat").document("\(NSDate.timeIntervalSinceReferenceDate)").setData([
            "type": "message",
            "message": message,
            "owner": UserManager.sharedInstance.auth.currentUser!.uid
            ])
        }
    }

