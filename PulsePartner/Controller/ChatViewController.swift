//
//  ChatViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

//The Message Layout was created with MessageKit
//Source: https://messagekit.github.io
internal struct MockMessage: MessageType {
    var sender: Sender

    var messageId: String

    var sentDate: Date

    var kind: MessageKind

    init(sender: Sender, messageId: String, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = Date()
        self.kind = kind
        print(self.sentDate)
    }
}
import UIKit
import MessageKit
import MessageInputBar
import Messages
import MessageUI
import CoreData

class ChatViewController: MessagesViewController {

    var user: MatchWithImage!
    var picture = UIImage()
    var name = ""
    var messages: [MockMessage] = []
    var messageCounter: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        ChatManager.shared.addObserver(self)
        insertMessages()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?
            .navigationBar
            .titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.title = user.matchData.username
    }

    override func viewDidAppear(_ animated: Bool) {
        messageCounter.setTitle("", for: .normal)
        messageCounter.setBackgroundImage(UIImage(), for: .normal)
    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    func insertMessages() {
        messages = ChatManager.shared.fetchMessages(matchID: user.matchData.userID)
        messagesCollectionView.reloadDataAndKeepOffset()
        messagesCollectionView.scrollToBottom(animated: true)
    }

}

extension ChatViewController: ChatObserver {
    func messageData(didUpdate messages: [NSManagedObject]?) {
        self.insertMessages()
    }
}
