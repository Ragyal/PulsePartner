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
    }
}
import UIKit
import MessageKit
import MessageInputBar
import Messages
import MessageUI

class ChatViewController: MessagesViewController {

    var user: User!
    var picture = UIImage()
    var name = ""
    var messages: [MessageType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        ChatManager.sharedInstance.fetchMessages(userID: user.userID, view: self)
        self.hideKeyboardWhenTappedAround()
        self.navigationController?
            .navigationBar
            .titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.title = user.name

    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    func insertMessage(_ message: MockMessage) {
        messages.append(message)
        messagesCollectionView.reloadData()
    }

}
