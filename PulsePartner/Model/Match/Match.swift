//
//  Match.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 10.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

struct Match {
    var userID: String
    var username: String
    var image: String
    var age: Int
    var gender: String
}

extension Match: FirestoreModel {
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
                       gender: modelData.value(forKey: "gender")
        )
    }
}

struct MatchWithImage {
    var matchData: Match
    var image: UIImage
}
