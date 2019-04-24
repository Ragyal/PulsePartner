//
//  ViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 04.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    @IBAction func showController(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if usernameTextField.text! == "lover69" && passwordTextField.text! == "1234" {
                let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainPage") as? MainViewController
                self.navigationController?.pushViewController(viewController!, animated: true)
            }
        case 2:
            let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterPage1") as? RegisterViewController
            self.navigationController?.pushViewController(viewController!, animated: true)
        default:
            break
        }
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
