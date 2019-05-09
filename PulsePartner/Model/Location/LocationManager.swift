//
//  LocationManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 03.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class LocationManager: UIViewController, CLLocationManagerDelegate {
        let manager = CLLocationManager()

    func determineMyCurrentLocation() -> [String] {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            print("Start Updating")
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
            let userLocation = ["\(manager.location!.coordinate.latitude)",
                "\(manager.location!.coordinate.longitude)"]
            return userLocation
        }
        let error = ["Zugriff verweigert", "Bitte Einstellungen pruefen"]
        return error
    }

    func getDistance (from location: CLLocation) -> Int {
        return Int(manager.location!.distance(from: location))
    }

}
