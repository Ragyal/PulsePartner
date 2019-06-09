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
    private var lastUpdate: Date = Date()

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
// https://developer.apple.com/documentation/corelocation/cllocationmanager/1620553-pauseslocationupdatesautomatical
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = CLActivityType.fitness
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if lastUpdate.timeIntervalSinceNow.magnitude < 15 {
            return
        }
        guard let mostRecentLocation = locations.last else {
            return
        }

        UserManager.sharedInstance.updateMatchData(coordinates: mostRecentLocation.coordinate)
        lastUpdate = Date()
    }
}
