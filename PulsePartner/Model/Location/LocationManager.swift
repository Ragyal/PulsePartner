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
    static let shared = LocationManager()

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

    /**
     Starts the generation of updates that report the user’s current location.
     */
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    /**
     Stops the generation of location updates.
     */
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    /**
     If a specified amount of time has passed since last update the UserManager gets invoked to updateMatchData.
     - parameters:
        - manager: The location manager object that generated the update event.
        - locations: An array of CLLocation objects containing the location data.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if lastUpdate.timeIntervalSinceNow.magnitude < 15 {
            return
        }
        guard let mostRecentLocation = locations.last else {
            return
        }

        UserManager.shared.updateMatchData(coordinates: mostRecentLocation.coordinate)
        lastUpdate = Date()
    }
}
