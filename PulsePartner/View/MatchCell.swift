//
//  MatchCell.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CoreData

class MatchCell: UITableViewCell {

    @IBOutlet weak var messageCounter: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    var matchImage: UIImage!
    var navController = UINavigationController()
    var matchID: String!

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }

    func insertContent(match: Match) {
        matchID = match.userID
        self.profilePicture.kf.setImage(with: URL(string: match.image))
        let size = CGSize(width: 90, height: 90)
        let rect = CGRect(x: 0, y: 0, width: 90, height: 90)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        profilePicture.image?.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.profilePicture.image = resizedImage
        self.nameLabel.text = match.username
        self.ageLabel.text = "\(match.age)"
        ChatManager.shared.addObserver(self)
        ChatManager.shared.activateObserver(matchID: match.userID)
    }
}

extension MatchCell: ChatObserver {
    func messageData(didUpdate messages: [NSManagedObject]?) {
        let unreadMessages = ChatManager.shared.countUnreadMessages(matchID: matchID)
        if unreadMessages == 0 {
            messageCounter.setBackgroundImage(UIImage(), for: .normal)
        } else {
            messageCounter.setBackgroundImage(UIImage(named: "newMessageIcon"), for: .normal)
        }
        messageCounter.setTitle("\(unreadMessages)", for: .normal)
    }
}
