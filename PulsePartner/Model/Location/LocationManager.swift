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

class LocationManager: NSObject, CLLocationManagerDelegate {

    // Singleton
    static let sharedInstance = LocationManager()

    let manager = CLLocationManager()

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
    }

    func determineMyCurrentLocation() -> [String] {
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
