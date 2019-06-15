//
//  User.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 01.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import FirebaseFirestore

struct UserRegisterData {
    var username: String
    var email: String
    var password: String
    var age: Int
    var weight: Int
    var fitnessLevel: Int
    var gender: String
    var preferences: [String]
}

struct GenderSettings {
    var ownGender: String
    var preferences: [String]
}

struct FullUser {
    var userID: String
    var username: String
    var email: String
    var image: String
    var age: Int
    var weight: Int
    var fitnessLevel: Int
    var gender: String
    var preferences: [String]
    var fcmToken: String?
}

extension FullUser: FirestoreModel {
    var documentID: String! {
        return userID
    }

    var customID: String? {
        return "userID"
    }

    init?(modelData: FirestoreModelData) {
        try? self.init(userID: modelData.documentID,
                       username: modelData.value(forKey: "username"),
                       email: modelData.value(forKey: "email"),
                       image: modelData.value(forKey: "image"),
                       age: modelData.value(forKey: "age"),
                       weight: modelData.value(forKey: "weight"),
                       fitnessLevel: modelData.value(forKey: "fitnessLevel"),
                       gender: modelData.value(forKey: "gender"),
                       preferences: modelData.value(forKey: "preferences"),
                       fcmToken: modelData.value(forKey: "fcmToken")
        )
    }

    init(userID: String, registerData: UserRegisterData, imageURL: URL) {
        self.init(userID: userID,
                  username: registerData.username,
                  email: registerData.email,
                  image: imageURL.absoluteString,
                  age: registerData.age,
                  weight: registerData.weight,
                  fitnessLevel: registerData.fitnessLevel,
                  gender: registerData.gender,
                  preferences: registerData.preferences,
                  fcmToken: nil
        )
    }
}
