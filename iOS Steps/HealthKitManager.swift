//
//  HealthKitManager.swift
//  iOS Steps
//
//  Created by Steve on 30/01/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitManager {
    
    let healthStore = HKHealthStore()

    
    init()
    {
        print ("HealthKitManager.init")
        checkHealthKitAuthorization()
    }
    
    
    func getDateOfBirth() -> Date
    {
        let dateOfBirthComponents = try? healthStore.dateOfBirthComponents()
        let dateOfBirth = Calendar.current.date(from: dateOfBirthComponents!)
        return dateOfBirth!
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
                let totalSteps = quantity?.doubleValue(for: unit)
                // print("totalSteps are \(totalSteps!)")
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
