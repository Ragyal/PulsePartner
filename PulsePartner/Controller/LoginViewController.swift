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

    /**
        Checks if the user is already logged in after the view has appeared
     - Parameters:
        - Animated: Specifies whether the change between views is animated
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserManager.shared.authenticated {
            self.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
        }
    }

    /**
     Call the signIn method in the UserManager to authenticate the user
     - Parameters:
        - Sender: Button that was pressed
     */
    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        UserManager.shared.signIn(withEmail: emailInput.text ?? "",
                                          password: passwordInput.text ?? "",
                                          sender: self) { result in
            if result {
                self.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
            }
        }
    }
    /**
     Called when the text field is selected. Calls the function animateViewMoving
     - Parameters:
        - Sender: Specifies TextField that was slected
     */
    @IBAction func mailEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 140)
    }
    /**
     Called if the text field is no longer selected. Calls the function animateViewMoving
     - Parameters:
        - Sender: Specifies TextField that was slected
     */
    @IBAction func mailEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 140)
    }
    @IBAction func passwordEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 220)
    }
    @IBAction func passwordEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 220)
    }

    /**
     Moves the view up or down to show the content behind the keyboard
     - Parameters:
        - MoveUp: Specifies if the view move up or down.
        - MoveValue: Specifies how far the view shifts
     */
    func animateViewMoving (moveUp: Bool, moveValue: CGFloat) {
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = ( moveUp ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
