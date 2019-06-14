//
//  RegisterFormViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 26.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CropViewController

class RegisterFormViewController: UIViewController {

    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var fitnessLevelLabel: UILabel!

    var imagePicker: UIImagePickerController!
    var image: UIImage?

    var fitnessLevel: Int = 1
    var genderSettings: GenderSettings?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func onPictureButtonClick(_ sender: Any) {
        ImageManager.handleImageUpload(self)
    }

    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLabel.text = String(Int(sender.value))
        fitnessLevel = Int(sender.value)
    }

    @IBAction func onRegisterButtonClick(_ sender: UIButton) {
        validateInput(completion: { data in
            if image == nil {
                image = UIImage(named: "PlaceholderImage")
            }
            let size = CGSize(width: 128, height: 128)
            let rect = CGRect(x: 0, y: 0, width: 128, height: 128)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            image!.draw(in: rect)
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UserManager.shared.createUser(withUserData: data,
                                                  image: resizedImage!,
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
            print("Email: Ungültige Email")
            return
        }
        guard let password = passwordInput.text else {
            return
        }
        guard let age = ageInput.intValue else {
            print("Age: kein Int")
            return
        }
        guard let weight = weightInput.intValue else {
            print("Weight: kein Int")
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
}

extension RegisterFormViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image: UIImage = info[.originalImage] as? UIImage else {
            return
        }
        presentCropViewController(withImage: image)
    }

    func presentCropViewController(withImage image: UIImage) {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
}

extension RegisterFormViewController: CropViewControllerDelegate {
    @objc func cropViewController(_ cropViewController: CropViewController,
                                  didCropToCircularImage image: UIImage,
                                  withRect cropRect: CGRect,
                                  angle: Int) {
        // 'image' is the newly cropped, circular version of the original image
        cropViewController.dismiss(animated: true, completion: nil)
        self.pictureButton.setImage(image, for: .normal)
        self.image = image
    }
}
