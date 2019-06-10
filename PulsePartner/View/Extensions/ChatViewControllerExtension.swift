//
//  ChatViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 07.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import Messages
import MessageUI

extension ChatViewController: MessagesDataSource {

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func currentSender() -> Sender {
        return Sender(id: UserManager.sharedInstance.auth.currentUser!.uid, displayName: "")
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
}

extension ChatViewController: MessagesLayoutDelegate {
//    func avatarSize(for message: MessageType,
//                    at indexPath: IndexPath,
//                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return .zero
//    }
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    func configureAvatarView(_ avatarView: AvatarView,
                             for message: MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) {
        if message.sender.id.elementsEqual(UserManager.sharedInstance.auth.currentUser!.uid) {
            avatarView.image = UserManager.sharedInstance.profilePicture
        } else {
            avatarView.image = user.image
        }
    }
}

extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        ChatManager.sharedInstance.sendMessage(receiver: user.matchData.userID, message: text)
        inputBar.inputTextView.text = ""
    }
}
