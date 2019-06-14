//
//  Chat.swift
//  PulsePartner
//
//  Created by yannik grotkop on 12.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation

struct Message {
    var userID: String
    var ownerID: String
    var chatID: String
    var date: Date
    var message: String
    var read: Bool
    var matchID: String
}
