//
//  HealthKitManager.swift
//  iOS Steps
//
//  Created by Steve on 30/01/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import Foundation
import HealthKit

var healthKitManager = HealthKitManager()


class HealthKitManager {
    
    let healthStore = HKHealthStore()

    
    init()
    {
        print ("HealthKitManager.init")
        checkHealthKitAuthorization()
        
        earliestPermittedSampleDate = healthStore.earliestPermittedSampleDate()
        
        let dateOfBirthComponents = try? healthStore.dateOfBirthComponents()
        dateOfBirth = Calendar.current.date(from: dateOfBirthComponents!)!
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        dateOfBirthSting = formatter.string(from: dateOfBirth)
        
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.year, .month, .day]
        ageFormatter.maximumUnitCount = 3
        ageString = ageFormatter.string(from: dateOfBirth, to: Date())!

    }
    
   
    var earliestPermittedSampleDate: Date = Date()
    var dateOfBirth: Date = Date()
    var dateOfBirthSting: String = ""
    var ageString: String = ""
    var stepsToday: Double = 0.0
    var stepsTodayString: String = ""
    var flightsClimbedToday: Double = 0.0
    var flightsClimbedTodayString = ""
    
    
    
    func getTodayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        let cal = Calendar(identifier: .gregorian)
        let startDate = cal.startOfDay(for: Date())
        
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            if results != nil {
                let quantity = results?.sumQuantity()
                let unit = HKUnit.count()
                let flights = quantity?.doubleValue(for: unit)
                
                self.flightsClimbedToday = flights!
                
                var pluralString = "s"
                if (flights != nil && Int(flights!) == 1) {
                    pluralString = ""
                }
                let numberFormatter = NumberFormatter()
                self.flightsClimbedTodayString = numberFormatter.string(from: flights! as NSNumber)! + " flight" + pluralString
                
                completion(flights)
            } else {
                print("getTodayStairCount: results are nil - returning zero flights")
                self.flightsClimbedToday = 0.0
                self.flightsClimbedTodayString = "0 flights"
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    func getTodayStepCount(completion:@escaping (Double?)->())
    {

        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let cal = Calendar(identifier: .gregorian)
        let startDate = cal.startOfDay(for: Date())
        
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            if results != nil {
                let quantity = results?.sumQuantity()
                let unit = HKUnit.count()
                let steps = quantity?.doubleValue(for: unit)

                self.stepsToday = steps!
               
                var pluralString = "s"
                if (steps != nil && Int(steps!) == 1) {
                    pluralString = ""
                }
                let numberFormatter = NumberFormatter()
                self.stepsTodayString = numberFormatter.string(from: steps! as NSNumber)! + " step" + pluralString

                completion(steps)
             } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                self.stepsToday = 0.0
                self.stepsTodayString = "0 steps"
                completion(0.0)
             }
        }
        healthStore.execute(query)
    }
    
    
    func getStepCountBetween(startDate: Date, endDate: Date, completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            if results != nil {
                let quantity = results?.sumQuantity()
                let unit = HKUnit.count()
                let totalSteps = quantity?.doubleValue(for: unit)
                completion(totalSteps)
            } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    

    func checkHealthKitAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            print ("healthKit is available")
 
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.flightsClimbed)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!
            ]
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
                if (error != nil) {
                    isHealthKitEnabled = true
                } else {
                    isHealthKitEnabled = false
                }
            }
        } else {
            isHealthKitEnabled = false
        }

        return isHealthKitEnabled
    }
}
