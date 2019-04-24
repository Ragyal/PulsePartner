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
        profilePicture.image = picture
        nameLabel.text = name
        // Do any additional setup after loading the view.
    }

    func setProfile(image: UIImage, name: String) {
        picture = image
        self.name = name
    }

    @IBAction func goBack(_ sender: UIButton) {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainPage") as? MainViewController
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
}
