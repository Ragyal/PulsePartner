//
//  UITextField.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 09.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    var floatValue: Float? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let nsNumber = numberFormatter.number(from: text!)
        return nsNumber?.floatValue
    }

    var intValue: Int? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none

        let nsNumber = numberFormatter.number(from: text!)
        return nsNumber?.intValue
    }
}
