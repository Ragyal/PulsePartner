//
//  MatchCell.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var messageCounter: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    var navController = UINavigationController()
    var user: User!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func insertContent(image: UIImage,
                       name: String,
                       age: String,
                       bpm: String,
                       navigation: UINavigationController) {
            self.profilePicture.image = image
            self.nameLabel.text = name
            self.ageLabel.text = "Age: \(age)"
            self.bpmLabel.text = "Weight: \(bpm)"
            self.navController = navigation
    }

    @IBAction func openChat(_ sender: UIButton) {
        let viewController = UIStoryboard.init(name: "Main",
                                               bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "ChatPage") as? ChatViewController
        viewController?.setProfile(image: profilePicture.image!, name: nameLabel.text!)
        navController.pushViewController(viewController!, animated: true)
    }
}
