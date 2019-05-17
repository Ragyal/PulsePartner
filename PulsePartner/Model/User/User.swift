//
//  User.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 01.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

struct User {
    var userID: Int
    var image: String
    var name: String
    var age: Int
    var bpm: Int
}

struct UserRegisterData {
    var username: String
    var email: String
    var password: String
    var age: Int
    var weight: Float
    var fitnessLevel: Int
    var gender: String
    var preferences: [String]
}

struct GenderSettings {
    var ownGender: String
    var preferences: [String]
}
