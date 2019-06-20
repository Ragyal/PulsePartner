//
//  ImageManager.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 16.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import Photos
import CropViewController

class ImageManager {

    /**
     Creates an ActionSheet AlertController showing options where to pick an image.
     - Parameters:
        - sender: Sending UIViewController and ImagePicker delegate which should
                    display AlertControllers and the resulting ActionSheet.
     */
    static func handleImageSelection(_ sender: UIViewController &
        UINavigationControllerDelegate &
        UIImagePickerControllerDelegate) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = sender

        let alertController = UIAlertController(title: nil,
                                                message: "Where do you want to select the picture?",
                                                preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert: UIAlertAction!) -> Void in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {

                let alertController = UIAlertController.init(title: nil,
                                                             message: "Device has no camera.",
                                                             preferredStyle: .alert)

                let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(_: UIAlertAction!) in
                })

                alertController.addAction(okAction)
                sender.present(alertController,
                             animated: true,
                             completion: nil)
            } else {
                imagePicker.sourceType = .camera

                sender.present(imagePicker,
                             animated: true,
                             completion: nil)
            }
        }

        let libraryAction = UIAlertAction(title: "Library", style: .default) { (_: UIAlertAction!) -> Void in
            if requestLibraryAuthentication() {
                imagePicker.sourceType = .savedPhotosAlbum
                sender.present(imagePicker, animated: true, completion: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction!) -> Void in
            //  Do something here upon cancellation.
        }

        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)

        sender.present(alertController, animated: true, completion: nil)
    }

    /**
     Checks permissions to access the users library and requests them if not already granted
     - Returns: True if access is granted.
     */
    static private func requestLibraryAuthentication() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .notDetermined:
            print("It is not determined until now. Requesting ...")
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus !=  PHAuthorizationStatus.authorized {
                    print("User has denied the permission.")
                    return
                }
            })
            return requestLibraryAuthentication()
        case .restricted:
            print("User do not have access to photo album.")
            return false
        case .denied:
            print("User has denied the permission.")
            return false
        case .authorized:
            print("Access is granted by user")
            return true
        @unknown default:
            print("Unknown state.")
            return false
        }
    }
}
