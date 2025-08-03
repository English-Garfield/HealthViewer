//
//  HealthManager.swift
//  HealthViewer
//
//  Created by Isaac on 03/08/2025.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var heartRate: Double = 0
    @Published var stepCount: Double = 0

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchHeartRate()
                self.fetchStepCount()
            }
        }
    }

    func fetchHeartRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        healthStore.execute(query)
    }

    func fetchStepCount() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            if let sum = stats?.sumQuantity() {
                DispatchQueue.main.async {
                    self.stepCount = sum.doubleValue(for: HKUnit.count())
                }
            }
        }
        healthStore.execute(query)
    }
}
