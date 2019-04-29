//
//  RegisterFormViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 26.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import Firebase

class RegisterFormViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var firstnameInput: UITextField!
    @IBOutlet weak var lastnameInput: UITextField!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var fitnessLevelLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLabel.text = String(Int(sender.value))
    }

    @IBAction func onButtonClick(_ sender: UIButton) {
        if !validateInput() {
            return
        }

        Auth.auth().createUser(withEmail: emailInput.text!, password: passwordInput.text!) { (user, error) in
            if error == nil {
                guard let user = Auth.auth().currentUser else {
                    return
                }
                let email = user.email ?? ""
                let uid = user.uid
                let message = "Email: " + email + "\nUID: " + uid

                let alertController = UIAlertController(title: "New User", message: message, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                    self.performSegue(withIdentifier: "ThirdRegisterSegue", sender: self)
                })

                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func validateInput() -> Bool {
        var isValid: Bool = true

        isValid = passwordInput.hasText
        isValid = emailInput.hasText

        return isValid
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
