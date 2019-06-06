//
//  ChatViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    var messageListener: ListenerRegistration?
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var user: User!
    var picture = UIImage()
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatManager.sharedInstance.fetchMessages()
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
}

