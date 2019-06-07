//
//  ChatViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//
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

    @IBOutlet weak var messageBox: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageField: UITextField!
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
//        self.navigationController?.isNavigationBarHidden = false
        self.hideKeyboardWhenTappedAround()
        profilePicture.image = user.profilePicture
        nameLabel.text = user.name

    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendMessage(_ sender: UIButton) {
        ChatManager.sharedInstance.sendMessage(receiver: user.userID, message: messageField.text!)
        messageField.text? = ""
    }
    func insertMessage(_ message: MockMessage) {
        messages.append(message)
        messagesCollectionView.reloadData()
    }

}
