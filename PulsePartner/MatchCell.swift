//
//  MatchCell.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    var navController = UINavigationController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func insertContent(image: String, name: String, age: String, bpm: String, navigation: UINavigationController) {
        profilePicture.image = UIImage(named: image)
        nameLabel.text = name
        ageLabel.text = age
        bpmLabel.text = bpm
        navController = navigation
    }

    @IBAction func openChat(_ sender: UIButton) {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatPage") as? ChatViewController
        viewController?.setProfile(image: profilePicture.image!, name: nameLabel.text!)
        navController.pushViewController(viewController!, animated: true)
    }
}