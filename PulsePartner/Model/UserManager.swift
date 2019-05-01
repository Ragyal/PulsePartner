//
//  UserManager.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 01.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    
    // Singleton
    static let sharedInstance = UserManager()
    
    private init() {
        
    }
    
    public func createUser(withEmail email: String, password: String, sender: UIViewController) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                let email = user?.user.email ?? ""
                let uid = user?.user.uid ?? ""
                let message = "Email: " + email + "\nUID: " + uid
                
                let alertController = UIAlertController(title: "New User", message: message, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
                    sender.performSegue(withIdentifier: "ThirdRegisterSegue", sender: self)
                })
                
                alertController.addAction(defaultAction)
                sender.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                sender.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    public func signIn(withEmail email: String, password: String, sender: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil {
                sender.performSegue(withIdentifier: "MainNavigationSegue", sender: self)
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                sender.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
