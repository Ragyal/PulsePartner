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

    @IBOutlet weak var gpsCheckbox: UIButton!
    @IBOutlet weak var pushCheckbox: UIButton!
    @IBOutlet weak var healthKitCheckbox: UIButton!

    lazy var permissionCheckboxes = [gpsCheckbox, pushCheckbox, healthKitCheckbox]

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.isNavigationBarHidden = false
//        self.hideKeyboardWhenTappedAround()

        if self.restorationIdentifier! == "RegisterPage3" {
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
                let alert = UIAlertController(title: "Location Services disabled",
                                              message: "Bitte erlaube den Zugriff auf deine GPS Daten.",
                                              preferredStyle: .alert)
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
     Function to push the controller with identifier `String`
     */
    func pushController(with identifier: String) {
        let viewController = UIStoryboard.init(name: "Main",
                                               bundle: Bundle.main)
            .instantiateViewController(withIdentifier: identifier) as? RegisterViewController
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
}
