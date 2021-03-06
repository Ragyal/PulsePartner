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

    /**
     Fetch all messages for the match partner from the internal memory with core data
     - Parameters:
        - matchID: The userID of the match partner
     - Returns:
        - mockMessages: All messages as MockMessage
     */
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
        let sort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "matchID = %@ AND ownID = %@",
                                             "\(matchID)", UserManager.shared.auth.currentUser!.uid)
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

    /**
     Stores the message in firebase at the match partner and at the current user.
     Additionally the message is stored on the internal memory.
     - Parameters:
        - receiver: The match user ID
        - message: The message text
     */
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
        saveMessage(message: Message(userID: ownID,
                                     ownerID: ownID,
                                     chatID: "\(chatID)",
                                     date: Date(),
                                     message: message,
                                     read: true,
                                     matchID: receiver)
        )
    }

    /**
     Counts all the messages from the match partner
     - Parameters:
        - matchID: The match user ID
     - Returns:
        - result.count: The count of unread messages as Int
     */
    func countUnreadMessages(matchID: String) -> Int {
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

    /**
     Activate the observer to listen for updates in the chat collection in firebase.
     If a new message is received, it is stored in the internal memory.
     - Parameters:
        - matchID: The matchID to register the listener
     */
    func activateObserver(matchID: String) {
        let ownID = UserManager.shared.auth.currentUser!.uid
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntitie")
                fStore
                    .collection("users")
                    .document(ownID)
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
                                    self.saveMessage(message: Message(userID: ownID,
                                                             ownerID: (message.get("owner") as? String)!,
                                                             chatID: message.documentID,
                                                             date: Date(),
                                                             message: (message.get("message") as? String)!,
                                                             read: (message.get("read") as? Bool)!,
                                                             matchID: (message.get("owner") as? String)!))
                                }

                            } catch {
                                print("Failed")
                            }
                        }
                }
    }

    /**
     A Function to save a message on the internal memory
     - Parameters:
        - message: The full message
     */
    func saveMessage(message: Message) {
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
        newMessage.setValue("\(message.chatID)", forKeyPath: "chatID")
        newMessage.setValue(Date(), forKeyPath: "date")
        newMessage.setValue(message.matchID, forKeyPath: "matchID")
        newMessage.setValue(message.message, forKeyPath: "message")
        newMessage.setValue(message.ownerID, forKeyPath: "ownerID")
        newMessage.setValue(message.read, forKeyPath: "read")
        newMessage.setValue(message.userID, forKey: "ownID")

        do {
            try managedContext.save()
            messages.append(newMessage)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension ChatManager {
    struct Observation {
        weak var observer: ChatObserver?
    }
}

extension ChatManager {
    /**
     Add the ChatObserver to the observer array
     - Parameters:
        - observer: The ChatObserver
     */
    func addObserver(_ observer: ChatObserver) {
        let oid = ObjectIdentifier(observer)
        observations[oid] = Observation(observer: observer)
        observer.messageData(didUpdate: messages)
    }
    /**
     Removes an observer from the observer array
     - Parameters:
        - observer: The ChatObserver
     */
    func removeObserver(_ observer: ChatObserver) {
        let oid = ObjectIdentifier(observer)
        observations.removeValue(forKey: oid)
    }
}

private extension ChatManager {
    /**
     Will execute the messageData function
     */
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
