//
//  HealthKitManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 16.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {

    static let shared = HealthKitManager()
    let healthStore: HKHealthStore?

    let readableHKQuantityTypes: Set<HKQuantityType>?
    let writeableHKQuantityTypes: Set<HKQuantityType>?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()

            readableHKQuantityTypes = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
            writeableHKQuantityTypes = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]

            healthStore?.requestAuthorization(toShare: writeableHKQuantityTypes,
                                              read: readableHKQuantityTypes,
                                              completion: { (success, error) -> Void in
                                                if success {
                                                    print("Successful authorized.")
                                                } else {
                                                    print(error.debugDescription)
                                                }
            })
        } else {
            self.healthStore = nil
            self.readableHKQuantityTypes = nil
            self.writeableHKQuantityTypes = nil
        }
    }

    func readHeartRateData(completion: @escaping ((Double) -> Void)) {
        var myAnchor: HKQueryAnchor?
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType,
                                          predicate: nil,
                                          anchor: myAnchor,
                                          limit: HKObjectQueryNoLimit) {
                                            (_, sampleOrNil, _, newAnchor, _) in
                                            myAnchor = newAnchor
                                            if let samples = sampleOrNil {
                                                if samples.count > 0 {
                                                    let lastBpm = (samples.last as? HKQuantitySample)!
                                                    completion(lastBpm.quantity.doubleValue(for: HKUnit.count()
                                                        .unitDivided(by: .minute())))
                                                } else {
                                                    completion(95.0)
                                                }
                                            } else {
                                                print("No heart rate samples available")
                                                completion(95.0)
                                            }
        }
        healthStore?.execute(query)

    }
}
