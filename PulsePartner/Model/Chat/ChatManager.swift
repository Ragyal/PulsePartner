//
//  ChatManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 06.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

class ChatManager {
    static let sharedInstance = ChatManager()
    let fStore: Firestore
    let fStorage: Storage

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }

    func fetchMessages(userID: String, view: ChatViewController) {
        fStore
            .collection("users")
            .document(UserManager.sharedInstance.auth.currentUser!.uid)
            .collection("matches")
            .document(userID)
            .collection("chat").whereField("type", isEqualTo: "message")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("ERROR!: \(error.debugDescription)")
                    return
                }
//                view.messages.removeAll()
                for (index, message) in documents.enumerated() {
                    view.insertMessage(MockMessage(sender: Sender(id: (message.get("owner") as? String)!,
                                                                  displayName: "Name"),
                                                   messageId: "\(index)",
                        kind: MessageKind.text((message.get("message") as? String)!)))
                }
        }
    }

    func sendMessage(receiver: String, message: String) {
        fStore.collection("users")
            .document(receiver)
            .collection("matches")
            .document(UserManager.sharedInstance.auth.currentUser!.uid).collection("chat")
            .document("\(NSDate.timeIntervalSinceReferenceDate)")
            .setData([
                "type": "message",
                "message": message,
                "owner": UserManager.sharedInstance.auth.currentUser!.uid,
                "date": Date()
            ])
         fStore.collection("users")
            .document(UserManager.sharedInstance.auth.currentUser!.uid)
            .collection("matches")
            .document(receiver)
            .collection("chat")
            .document("\(NSDate.timeIntervalSinceReferenceDate)").setData([
                "type": "message",
                "message": message,
                "owner": UserManager.sharedInstance.auth.currentUser!.uid,
                "date": Date()
            ])
        }
    }
