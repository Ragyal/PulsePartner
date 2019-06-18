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
import UserNotifications

class PermissionsViewController: UIViewController, CLLocationManagerDelegate {

    let healthManager = HKHealthStore()

    @IBOutlet weak var gpsCheckbox: UIButton!
    @IBOutlet weak var pushCheckbox: UIButton!
    @IBOutlet weak var healthKitCheckbox: UIButton!

    lazy var permissionCheckboxes = [gpsCheckbox, pushCheckbox, healthKitCheckbox]

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.isNavigationBarHidden = false
//        self.hideKeyboardWhenTappedAround()

        for checkbox in permissionCheckboxes {
            checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
            checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
        }
        setupHealthKitCheckbox()
        setupNotificationCheckbox()
        setupLocationCheckbox()
    }

    private func setupLocationCheckbox() {
        let locationStatus = CLLocationManager.authorizationStatus()
        switch locationStatus {
        case .notDetermined, .denied, .restricted:
            self.gpsCheckbox.isSelected = false
        case .authorizedAlways, .authorizedWhenInUse:
            self.gpsCheckbox.isSelected = true
        default:
            break
        }
    }

    private func setupNotificationCheckbox() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let notificationStatus = settings.authorizationStatus
            switch notificationStatus {
            case .notDetermined, .provisional, .denied:
                DispatchQueue.main.async {
                    self.pushCheckbox.isSelected = false
                }
            case .authorized:
                DispatchQueue.main.async {
                    self.pushCheckbox.isSelected = true
                }
            default:
                break
            }
        }
    }

    private func setupHealthKitCheckbox() {
        let hkStatus = HKHealthStore().authorizationStatus(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)
        switch hkStatus.rawValue {
        case 1:
            DispatchQueue.main.async {
                self.healthKitCheckbox.isSelected = false
            }
        case 2:
            DispatchQueue.main.async {
                self.healthKitCheckbox.isSelected = true
            }
        default:
            break
        }
    }

    @IBAction func askForGPS(_ sender: UIButton) {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.gpsCheckbox.isSelected = true
        case .notDetermined:
            LocationManager.shared.manager.requestAlwaysAuthorization()
            self.gpsCheckbox.isSelected = true
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
    }

    @IBAction func askForPushNotification(_ sender: UIButton) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.pushCheckbox.isSelected = false
                }
                return
            }
            DispatchQueue.main.async {
                self.pushCheckbox.isSelected = success
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    @IBAction func askForHealthKit(_ sender: UIButton) {
        let healthStore = HKHealthStore()
        var readableHKQuantityTypes: Set<HKQuantityType>?
        var writeableHKQuantityTypes: Set<HKQuantityType>?
        readableHKQuantityTypes = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        writeableHKQuantityTypes = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: writeableHKQuantityTypes,
                                              read: readableHKQuantityTypes,
                                              completion: { (success, error) -> Void in
                                                if success {
                                                    print("Successful authorized.")
                                                } else {
                                                    print(error.debugDescription)
                                                }
            })
        }
    }
}
