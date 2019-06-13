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

class ImageManager: NSObject {
    static let sharedInstance = ImageManager()
    
    var imagePicker: UIImagePickerController!
    var sender: UIViewController?
    
    override init() {
        super.init()
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
    }

    func handleImageUpload(_ sender: UIViewController) {
        self.sender = sender
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
                sender.present(alertController,
                             animated: true,
                             completion: nil)
            } else {
                self.imagePicker.sourceType = .camera
                
                sender.present(self.imagePicker,
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
            self.imagePicker.sourceType = .savedPhotosAlbum
            
            sender.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_: UIAlertAction!) -> Void in
            //  Do something here upon cancellation.
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        sender.present(alertController, animated: true, completion: nil)
    }
    
}

extension ImageManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        self.sender?.present(cropViewController, animated: true, completion: nil)
    }
}

extension ImageManager: CropViewControllerDelegate {
    @objc func cropViewController(_ cropViewController: CropViewController,
                                  didCropToCircularImage image: UIImage,
                                  withRect cropRect: CGRect,
                                  angle: Int) {
        // 'image' is the newly cropped, circular version of the original image
        cropViewController.dismiss(animated: true, completion: nil)
        pictureButton.setImage(image, for: .normal)
        self.image = image
    }
}
