//
//  ChatObserver.swift
//  PulsePartner
//
//  Created by yannik grotkop on 15.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import CoreData
import Firebase

protocol ChatObserver: class {
    func messageData(didUpdate messages: [NSManagedObject]?)
}

extension ChatObserver {
    func messageData(didUpdate messages: [NSManagedObject]?) {}
}
