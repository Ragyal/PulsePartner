//
//  UserObserver.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 09.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation

protocol UserObserver: class {
    func userData(didUpdate user: FullUser?)
}

extension UserObserver {
    func userData(didUpdate user: FullUser?) {}
}
