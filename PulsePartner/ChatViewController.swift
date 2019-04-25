//
//  ChatViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 24.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var picture = UIImage()
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
        self.hideKeyboardWhenTappedAround()
        profilePicture.image = picture
        nameLabel.text = name
    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
