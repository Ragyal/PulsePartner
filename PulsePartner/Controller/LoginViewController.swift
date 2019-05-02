//
//  ViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 04.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
            self.hideKeyboardWhenTappedAround()
//        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        UserManager.sharedInstance.signIn(withEmail: emailInput.text ?? "",
                                          password: passwordInput.text ?? "",
                                          sender: self) { result in
            if result {
                self.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
            }
        }
    }
}
