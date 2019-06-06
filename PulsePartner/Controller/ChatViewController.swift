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

    @IBOutlet weak var messageBox: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageField: UITextField!
    var user: User!
    var picture = UIImage()
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
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

}

