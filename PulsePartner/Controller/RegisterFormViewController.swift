//
//  RegisterFormViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 26.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class RegisterFormViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var fitnessLevelLabel: UILabel!

    var imagePicker: UIImagePickerController!
    
    var fitnessLevel: Int = 1
    var genderSettings: GenderSettings?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLabel.text = String(Int(sender.value))
        fitnessLevel = Int(sender.value)
    }

    @IBAction func onPictureButtonClick(_ sender: Any) {
        let alertController = UIAlertController(title: nil,
                                                message: "Where do you want to select the picture?",
                                                preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let alertController = UIAlertController.init(title: nil, message: "Device has no camera. Please test on real device", preferredStyle: .alert)
                
                let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
                })
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        
        let deleteAction = UIAlertAction(title: "Library", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            //  Do something here upon cancellation.
        })
        
        alertController.addAction(defaultAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onRegisterButtonClick(_ sender: UIButton) {
        validateInput(completion: { data in
            UserManager.sharedInstance.createUser(withUserData: data,
                                                  sender: self) { success in
                                                    if success {
                                                        self.performSegue(withIdentifier: "showPermissionsSegue",
                                                                          sender: self)
                                                    }
            }
        })
    }

    private func validateInput(completion: (UserRegisterData) -> Void) {
        guard let genderSettings = self.genderSettings else {
            return
        }
        guard let username = usernameInput.text else {
            return
        }
        guard let email = emailInput.text, email.isValidEmail else {
//            emailInput.layer.borderColor = UIColor.red.cgColor
//            emailInput.layer.borderWidth = 1.0
            return
        }
        guard let password = passwordInput.text else {
            return
        }
        guard let age = ageInput.intValue else {
            print("Age: kein Int")
            return
        }
        guard let weight = weightInput.floatValue else {
            print("Age: kein Float")
            return
        }

        let registerData = UserRegisterData(username: username,
                                            email: email,
                                            password: password,
                                            age: age,
                                            weight: weight,
                                            fitnessLevel: fitnessLevel,
                                            gender: genderSettings.ownGender,
                                            preferences: genderSettings.preferences)
        completion(registerData)
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
