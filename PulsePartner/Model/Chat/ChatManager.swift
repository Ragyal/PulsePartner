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
import CoreData

class ChatManager {

    // Singleton
    static let shared = ChatManager()

    let fStore: Firestore
    let fStorage: Storage
    var messageDataListener: ListenerRegistration?
    var messages: [NSManagedObject] = [] {
        didSet { stateDidChange() }
    }
    private var observations = [ObjectIdentifier: Observation]()

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }
//
//    func messagesListener(snapshot: QuerySnapshot?, error: Error?) {
//        if error != nil {
//            print(error!.localizedDescription)
//            return
//        }
//
//        var messages: [NSManagedObject] = []
//        guard let message = Message
//    }

    func fetchMessages(matchID: String) -> [MockMessage] {
        var newMessages: [NSManagedObject] = []
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                let emptyMessages: [MockMessage] = []
                return emptyMessages
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MessageEntitie")
        fetchRequest.predicate = NSPredicate(format: "matchID = %@", "\(matchID)")
        do {
            newMessages = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        var mockMessages: [MockMessage] = []
        for message in newMessages {
            message.setValue(true, forKey: "read")
            mockMessages.append(MockMessage(sender: Sender(id: (message.value(forKey: "ownerID") as? String)!,
                                                           displayName: ""),
                                            messageId: (message.value(forKey: "chatID") as? String)!,
                                            kind: MessageKind.text((message.value(forKey: "message") as? String)!))
            )
        }
        return mockMessages
    }

    func sendMessage(receiver: String, message: String) {
        guard let ownID = UserManager.shared.auth.currentUser?.uid else {
            print("User ID not found")
            return
        }
        let chatID = NSDate.timeIntervalSinceReferenceDate
        fStore.collection("users")
            .document(receiver)
            .collection("matches")
            .document(ownID).collection("chat")
            .document("\(chatID)")
            .setData([
                "type": "message",
                "message": message,
                "owner": ownID,
                "date": Date(),
                "read": false,
                "matchID": ownID
                ])
        fStore.collection("users")
            .document(ownID)
            .collection("matches")
            .document(receiver)
            .collection("chat")
            .document("\(chatID)").setData([
                "type": "message",
                "message": message,
                "owner": ownID,
                "date": Date(),
                "read": true,
                "matchID": receiver
                ])
        saveMessage(chatID: "\(chatID)",
                    date: Date(),
                    matchID: receiver,
                    message: message,
                    ownerID: ownID,
                    read: true)
    }

    func countUnreadMessages(matchID: String) -> Int{
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntitie")
        let matchPredicate = NSPredicate(format: "ownerID == %@", matchID)
        let readPredicate = NSPredicate(format: "read == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchPredicate, readPredicate])
        do {
            let result = try managedContext.fetch(request)
            return result.count
        } catch {
            print("faild to count unread messages")
            return 0
        }
    }

    func activateObserver(matchID: String) {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntitie")
                fStore
                    .collection("users")
                    .document(UserManager.shared.auth.currentUser!.uid)
                    .collection("matches")
                    .document(matchID)
                    .collection("chat").whereField("type", isEqualTo: "message")
                    .addSnapshotListener { querySnapshot, error in
                        guard let documents = querySnapshot?.documents else {
                            print("ERROR!: \(error.debugDescription)")
                            return
                        }
                        for message in documents {
                            request.predicate = NSPredicate(format: "chatID = %@", "\(message.documentID)")
                            do {
                                let result = try managedContext.fetch(request)
                                if result.count == 0 {
                                    self.saveMessage(chatID: message.documentID,
                                                     date: Date(),
                                                     matchID: (message.get("owner") as? String)!,
                                                     message: (message.get("message") as? String)!,
                                                     ownerID: (message.get("owner") as? String)!,
                                                     read: (message.get("read") as? Bool)!)
//                                    if view is ChatViewController {
//                                        let chatView = (view as? ChatViewController)!
//                                        print("--->New Message in Chatview<---")
//                                        chatView.fetchMessages()
//                                    } else if view is MatchCell {
//                                        print("--->New Message in MatchCell<---")
//                                        let cellView = (view as? MatchCell)!
//                                        cellView.getNewMessageCount()
//                                    } else {
//                                        print("--->wrong View<---")
//                                    }
                                }

                            } catch {
                                print("Failed")
                            }
                        }
                }
    }

    func saveMessage(chatID: String,
                     date: Date,
                     matchID: String,
                     message: String,
                     ownerID: String,
                     read: Bool) {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity =
            NSEntityDescription.entity(forEntityName: "MessageEntitie",
                                       in: managedContext) else {
                                        print("Entitie not found")
                                        return
        }
        let newMessage = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        newMessage.setValue("\(chatID)", forKeyPath: "chatID")
        newMessage.setValue(Date(), forKeyPath: "date")
        newMessage.setValue(matchID, forKeyPath: "matchID")
        newMessage.setValue(message, forKeyPath: "message")
        newMessage.setValue(ownerID, forKeyPath: "ownerID")
        newMessage.setValue(read, forKeyPath: "read")

        do {
            try managedContext.save()
            messages.append(newMessage)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
//extension ChatManager: ChatObserver {
//    func messageData(didUpdate messages: [NSManagedObject]?, matchID: String) {
//        self.messageDataListener = fStore.collection("users").document(UserManager.shared.auth.currentUser!.uid).collection("matches").document(matchID).collection("chat").whereField("type", isEqualTo: "message").addSnapshotListener()
//
//    }
//}

extension ChatManager {
    struct Observation {
        weak var observer: ChatObserver?
    }
}

extension ChatManager {
    func addObserver(_ observer: ChatObserver) {
        let oid = ObjectIdentifier(observer)
        observations[oid] = Observation(observer: observer)
        observer.messageData(didUpdate: messages)
    }

    func removeObserver(_ observer: ChatObserver) {
        let oid = ObjectIdentifier(observer)
        observations.removeValue(forKey: oid)
    }
}

private extension ChatManager {
    func stateDidChange() {
        for (oid, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: oid)
                continue
            }
            
            observer.messageData(didUpdate: messages)
        }
    }
}
