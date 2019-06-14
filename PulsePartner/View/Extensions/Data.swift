//
//  Data.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 14.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
