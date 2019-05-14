//
//  RegisterFormViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 26.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CropViewController
import Photos

class RegisterFormViewController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate {

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
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self

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

        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {

                let alertController = UIAlertController.init(title: nil,
                                                             message: "Device has no camera.",
                                                             preferredStyle: .alert)

                let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(_: UIAlertAction!) in
                })

                alertController.addAction(okAction)
                self.present(alertController,
                             animated: true,
                             completion: nil)
            } else {
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.sourceType = .camera

                self.present(self.imagePicker,
                             animated: true,
                             completion: nil)
            }
        })

        let libraryAction = UIAlertAction(title: "Library", style: .default, handler: { (_: UIAlertAction!) -> Void in
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus !=  PHAuthorizationStatus.authorized {
                        print("User has denied the permission.")
                        return
                    }
                })
                print("It is not determined until now")
            case .restricted:
                print("User do not have access to photo album.")
                return
            case .denied:
                print("User has denied the permission.")
                return
            case .authorized:
                    print("Access is granted by user")
            @unknown default:
                print("Unknown state.")
                return
            }
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.sourceType = .savedPhotosAlbum

            self.present(self.imagePicker, animated: true, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_: UIAlertAction!) -> Void in
            //  Do something here upon cancellation.
        })

        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @objc private func imagePickerController(picker: UIImagePickerController,
                                             didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("dismissed")
        guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
            return
        }
//        presentCropViewController(withImage: image)
    }

//    func presentCropViewController(withImage image: UIImage) {
//        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
//        cropViewController.delegate = self
//        self.present(cropViewController, animated: true, completion: nil)
//    }
//
//    private func cropViewController(_ cropViewController: TOCropViewController?,
//                                    didCropToCircularImage image: UIImage?,
//                                    with cropRect: CGRect,
//                                    angle: Int) {
//        // 'image' is the newly cropped, circular version of the original image
//    }

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
