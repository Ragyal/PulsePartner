//
//  RegisterViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 12.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class RegisterViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    let healthManager = HKHealthStore()
    @IBOutlet weak var maleOneCheckbox: UIButton!
    @IBOutlet weak var femaleOneCheckbox: UIButton!
    @IBOutlet weak var maleSecondCheckbox: UIButton!
    @IBOutlet weak var femaleSecondCheckbox: UIButton!
    @IBOutlet weak var fitnessLevelLab: UILabel!
    @IBOutlet weak var gpsCheckbox: UIButton!
    @IBOutlet weak var pushCheckbox: UIButton!
    @IBOutlet weak var healthKitCheckbox: UIButton!

    lazy var checkboxes = [maleOneCheckbox, femaleOneCheckbox, maleSecondCheckbox, femaleSecondCheckbox]

    lazy var permissionCheckboxes = [gpsCheckbox, pushCheckbox, healthKitCheckbox]

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
        self.hideKeyboardWhenTappedAround()
        if self.restorationIdentifier! == "RegisterPage1" {
            for checkbox in checkboxes {
                checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
                checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
            }
        } else if self.restorationIdentifier! == "RegisterPage3" {
            for checkbox in permissionCheckboxes {
                checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
                checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
            }
            let locationStatus = CLLocationManager.authorizationStatus()
            switch locationStatus {
            case .notDetermined, .denied, .restricted:
                gpsCheckbox.isSelected = false
            case .authorizedAlways, .authorizedWhenInUse:
                gpsCheckbox.isSelected = true
            default:
                break
            }
        }
    }

    /**
     Function to check if the other radio button is already selected
     */
    @IBAction func checkMarkTapped(_ sender: UIButton) {

        switch sender.tag {
        case 1...2:
            if sender.tag == 1 {
                femaleOneCheckbox.isSelected = false
            } else {
                maleOneCheckbox.isSelected = false
            }
        case 3...4:
            if sender.tag == 3 {
                femaleSecondCheckbox.isSelected = false
            } else {
                maleSecondCheckbox.isSelected = false
            }
        default:
            break
        }
//        sender.isSelected = !sender.isSelected
//        Animation for selection
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        }
    }

    /**
     Function to ask for access for
     `Location`, `HealthKit` and `PushNotification`
     - ToDo: Add request for HealthKit and PushNotification
     */
    @IBAction func askForPermission (_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let status = CLLocationManager.authorizationStatus()

            switch status {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                gpsCheckbox.isSelected = true
            case .denied, .restricted:
                let alert = UIAlertController(title: "Location Services disabled", message: "Bitte erlaube den Zugriff auf deine GPS Daten in den Einstellungen settings ->privacy->Location Services", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)

                present(alert, animated: true, completion: nil)
                return
            default:
                break
            }
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        case 2:
            pushCheckbox.isSelected = true
        case 3:
            healthKitCheckbox.isSelected = true
        default:
            break
        }
    }

    /**
     Function to change the displayed controller
     */
    @IBAction func changePage(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if !femaleOneCheckbox.isSelected && !maleOneCheckbox.isSelected || !femaleSecondCheckbox.isSelected && !maleSecondCheckbox.isSelected {
                let alert = UIAlertController(title: "Error!", message: "Please select a gender", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                pushController(with: "RegisterPage2")
            }
        case 2:
            pushController(with: "RegisterPage3")
        case 3:
            let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginPage") as? ViewController
            self.navigationController?.pushViewController(viewController!, animated: true)
        default:
            break
        }

    }

    /**
     Function to push the controller with identifier `String`
     */
    func pushController(with identifier: String) {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as? RegisterViewController
        self.navigationController?.pushViewController(viewController!, animated: true)
    }

    /**
     Function to set the text of the fitnessLevelLabel
     */
    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLab.text = String(Int(sender.value))
    }
}
