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

    /**
     Called if the pictureButton has been clicked. Calls the function handleImageSelection
     to open the image selection
     - Parameters:
        - sender: Specifies Button that was clicked
     */
    @IBAction func onPictureButtonClick(_ sender: Any) {
        ImageManager.handleImageSelection(self)
    }

    /**
     Called when the slider was moved. Sets the fitnessLevel and the text for the fitnessLevelLabel
     - Parameters:
        - sender: Specifies UISlider that was moved
     */
    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLabel.text = String(Int(sender.value))
        fitnessLevel = Int(sender.value)
    }

    /**
     Called when the register button was clicked. If an image was selected, it will be set, otherwise a placeholder image will be set.
     - Parameters:
        - sender: Specifies TextField that was slected
     */
    @IBAction func onRegisterButtonClick(_ sender: UIButton) {
        validateInput(completion: { data in
            if image == nil {
                image = data.gender == "m" ?
                    UIImage(named: "PlaceholderImageMale") :
                    UIImage(named: "PlaceholderImageFemale")
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

    /**
     A function to validate the content of input fields. After validation, the UserRegisterData will be returned
     - Parameters:
        - completion: This will give you call back inside block if the register progress is complete
     - Returns: UserRegisterData
     */
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

    /**
     Called when the text field is selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func emailEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 50)
    }
    /**
     Called if the text field is no longer selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 50)
    }
    /**
     Called when the text field is selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func ageEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 100)
    }
    /**
     Called if the text field is no longer selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func ageEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 100)
    }
    /**
     Called when the text field is selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func weightEditingDidBegin(_ sender: UITextField) {
        animateViewMoving(moveUp: true, moveValue: 150)
    }
    /**
     Called if the text field is no longer selected. Calls the function animateViewMoving
     - Parameters:
        - sender: Specifies TextField that was selected
     */
    @IBAction func weightEditingDidEnd(_ sender: UITextField) {
        animateViewMoving(moveUp: false, moveValue: 150)
    }

    /**
     Moves the view up or down to show the content behind the keyboard
     - Parameters:
        - moveUp: Specifies whether the view should move up or down.
        - moveValue: Specifies how far the view shifts
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
