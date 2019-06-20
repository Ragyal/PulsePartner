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

    /**
     Sets the images of the checkboxes according to selected status
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        for checkbox in permissionCheckboxes {
            checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
            checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
        }
        setupHealthKitCheckbox()
        setupNotificationCheckbox()
        setupLocationCheckbox()
    }

    /**
     Sets the selected status of the gpsCheckbox depending on the authorization status
     */
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

    /**
     Sets the selected status of the pushCheckbox depending on the authorization status
     */
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

    /**
     Sets the selected status of the healthKitCheckbox depending on the authorization status
     */
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

    /**
     Shows alert for gps authorization
     - Parameters:
        - sender: Specifies Button that was clicked
     */
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

    /**
     Shows alert for push notification authorization
     - Parameters:
        - sender: Specifies Button that was clicked
     */
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

    /**
     Shows menu for health kit authorization. Different HKQuantityTypes for read and write permission
     - Parameters:
        - sender: Specifies Button that was clicked
     */
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
                                                    self.healthKitCheckbox.isSelected = true
                                                    print("Successful authorized.")
                                                } else {
                                                    print(error.debugDescription)
                                                }
            })
        }
    }
}
