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

class ChatViewController: MessagesViewController {

    var newMessages: Int = 0 {
        didSet {
            if !self.view.isFocused {
                messageCounter.setTitle("\(newMessages)", for: .normal)
                messageCounter.setBackgroundImage(UIImage(named: "newMessageIcon"), for: .normal)
            }
        }
    }

    var user: Match!
    var picture = UIImage()
    var name = ""
    var messages: [MockMessage] = []
    var messageCounter: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        newMessages = 0
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        fetchMessages()
        ChatManager.shared.activateObserver(matchID: user.userID, view: self)
        self.hideKeyboardWhenTappedAround()
        self.navigationController?
            .navigationBar
            .titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.title = user.username
    }

    override func viewDidAppear(_ animated: Bool) {
        newMessages = 0
        messageCounter.setTitle("", for: .normal)
        messageCounter.setBackgroundImage(UIImage(), for: .normal)
    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    func insertMessage(_ message: MockMessage) {
        if !messages.contains(where: {$0.messageId == message.messageId}) {
            newMessages += 1
            messages.append(message)
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    func fetchMessages() {
        ChatManager.shared.fetchMessages(matchID: user.userID, view: self)
    }

}
