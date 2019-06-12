//
//  MatchObserver.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 10.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation

protocol MatchObserver: class {
    func matchData(didUpdate matches: [MatchWithImage]?)
}

extension MatchObserver {
    func matchData(didUpdate matches: [MatchWithImage]?) {}
}
