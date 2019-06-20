//
//  MainViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 23.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import CropViewController
import CoreData
import HealthKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIButton!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var noMatchesLabel: UILabel!

    static let shared = MainViewController()
    var allMatches = [Match]()

    /**
     Checks if health kit data is available and starts the timer schedule for setHeartRate function.
     Add the user, match and location observer.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = UserManager.shared.user {
            updateImage(user: user)
        }
        UserManager.shared.addObserver(self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if HKHealthStore.isHealthDataAvailable() {
            _ = Timer.scheduledTimer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(setHeartRate),
                                     userInfo: nil,
                                     repeats: true)
        }
        MatchManager.shared.addObserver(self)
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        LocationManager.shared.startUpdatingLocation()
    }

    /**
     Called if the profilePicture button has been clicked. Calls the function handleImageSelection
     to open the image selection
     - Parameters:
        - sender: Specifies Button that was clicked
     */
    @IBAction func onChangePicture(_ sender: UIButton) {
        ImageManager.handleImageSelection(self)
    }

    /**
     Called if the logout button has been clicked.
     Stops location updates, removes the match listener in MatchManager and
     calls the logout function in UserManager.
     - Parameters:
        - sender: Specifies Button that was clicked
     */
    @IBAction func onLogout(_ sender: Any) {
        LocationManager.shared.stopUpdatingLocation()
        MatchManager.shared.matchDataListener?.remove()
        UserManager.shared.logout()
    }

    /**
     Updates the image in profilePicture button. If the image is nil, a placeholder image is set
     - Parameters:
        - user: FullUser with the profile picture
     */
    func updateImage(user: FullUser) {
        var placeholder = self.profilePicture.image(for: .normal)
        if placeholder == nil {
            placeholder = user.gender == "m" ?
                UIImage(named: "PlaceholderImageMale") :
                UIImage(named: "PlaceholderImageFemale")
        }
        self.profilePicture.kf.setImage(with: URL(string: user.image), for: .normal, placeholder: placeholder)
    }

    /**
     Creates the MatchCells and sets the segue to the ChatViewController.
     Hide the noMatchesLabel if the count of cells is greater than zero
     - Parameters:
        - segue: The connection between the cell and the ChatViewController
        - sender: Specifies cell that was clicked
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }
        guard let destinationVC = segue.destination as? ChatViewController else {
            return
        }
        destinationVC.user = self.allMatches[indexPath.row]
        if allMatches.count > 0 {
            noMatchesLabel.isHidden = true
        }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MatchCell else {
            return
        }
        destinationVC.messageCounter = cell.messageCounter
    }

    /**
    Calls the readHeartRateData function and sets the returned value in bpmLabel
     */
    @objc func setHeartRate() {
        HealthKitManager.shared.readHeartRateData { file in
            DispatchQueue.main.async {
                self.bpmLabel.text! = "\(Int(file)) BPM"
            }
        }
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMatches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 110
        let cell = ( self.tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchCell )!

        let match = self.allMatches[indexPath.row]
        cell.insertContent(match: match)

        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "ChatSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ChatSegue", sender: indexPath)
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    /**
     Shows the image selection and call the presentCropViewController with the selected image
     - Parameters:
        - picker: UIImagePickerController
     */
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image: UIImage = info[.originalImage] as? UIImage else {
            return
        }
        presentCropViewController(withImage: image)
    }

    /**
     Shows the image crop view to crop the image
     - Parameters:
        - image: The selected image from the imagePickerController function
     */
    func presentCropViewController(withImage image: UIImage) {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
}

extension MainViewController: CropViewControllerDelegate {
    /**
     Crop the image and calls the updateProfilePicture function to set the new image
     - Parameters:
        - cropViewController: The CropViewController
        - image: The new image
        - cropRect: The CGRect for the new image
        - angle: The angle for the new circular version of the image
     */
    @objc func cropViewController(_ cropViewController: CropViewController,
                                  didCropToCircularImage image: UIImage,
                                  withRect cropRect: CGRect,
                                  angle: Int) {
        // 'image' is the newly cropped, circular version of the original image
        cropViewController.dismiss(animated: true, completion: nil)
        self.profilePicture.setImage(image, for: .normal)
        UserManager.shared.updateProfilePicture(image: image)
    }
}

extension MainViewController: UserObserver {
    /**
     Will be execudet when the user data is called in the UserManager
     - Parameters:
     - user: The full user with all informations
     */
    func userData(didUpdate user: FullUser?) {
        guard let user = user else {
            return
        }
        updateImage(user: user)
    }
}

extension MainViewController: MatchObserver {
    /**
     Will be execudet when the match data is called in the MatchManager
     - Parameters:
     - matches: All matches to fill the table view
     */
    func matchData(didUpdate matches: [Match]?) {
        if let matches = matches {
            if matches.count > 0 {
                noMatchesLabel.isHidden = true
            }
            self.allMatches = matches
            self.tableView.reloadData()
        }
    }
}
