//
//  ViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 04.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import NotificationCenter

class LoginViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!

    @IBOutlet weak var registerHeightContraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
            self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserManager.shared.authenticated {
            self.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
        }
    }

    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        UserManager.shared.signIn(withEmail: emailInput.text ?? "",
                                          password: passwordInput.text ?? "",
                                          sender: self) { result in
            if result {
                self.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
            }
        }
    }
    @IBAction func mailEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 140)
    }
    @IBAction func mailEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 140)
    }
    @IBAction func passwordEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 220)
    }
    @IBAction func passwordEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 220)
    }

    func animateViewMoving (moveUp: Bool, moveValue: CGFloat) {
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
