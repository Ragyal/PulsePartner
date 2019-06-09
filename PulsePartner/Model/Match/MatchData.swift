//
//  MatchData.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 09.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import CoreLocation
import FirebaseFirestore

struct MatchData {
    var userID: String
    var username: String
    var image: String
    var age: Int
    var weight: Int
    var fitnessLevel: Int
    var gender: String
    var preferences: [String]
    var heartrate: Int
    var location: GeoPoint
    var timestamp: Timestamp
}

extension MatchData: FirestoreModel {
    var documentID: String! {
        return userID
    }
    
    var customID: String? {
        return "userID"
    }
    
    init?(modelData: FirestoreModelData) {
        try? self.init(userID: modelData.documentID,
                       username: modelData.value(forKey: "username"),
                       image: modelData.value(forKey: "image"),
                       age: modelData.value(forKey: "age"),
                       weight: modelData.value(forKey: "weight"),
                       fitnessLevel: modelData.value(forKey: "fitnessLevel"),
                       gender: modelData.value(forKey: "gender"),
                       preferences: modelData.value(forKey: "preferences"),
                       heartrate: modelData.value(forKey: "heartrate"),
                       location: modelData.value(forKey: "location"),
                       timestamp: modelData.value(forKey: "timestamp")
        )
    }
    
    init(user: FullUser,
         heartrate: Int = 95,
         coordinates: CLLocationCoordinate2D,
         timestamp: Date = Date()) {
        
        self.init(userID: user.documentID,
                  username: user.username,
                  image: user.image,
                  age: user.age,
                  weight: user.weight,
                  fitnessLevel: user.fitnessLevel,
                  gender: user.gender,
                  preferences: user.preferences,
                  heartrate: heartrate,
                  location: GeoPoint(latitude: coordinates.latitude,
                                     longitude: coordinates.longitude),
                  timestamp: Timestamp(date: timestamp)
        )
    }
}
