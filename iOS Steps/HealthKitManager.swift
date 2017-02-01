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
    
    
    func getDateOfBirth() -> Date {
        let dateOfBirthComponents = try? healthStore.dateOfBirthComponents()
        let dateOfBirth = Calendar.current.date(from: dateOfBirthComponents!)
        return dateOfBirth!
    }
    
    
    func getTodayStepCount() -> Double {
         return 10.0
        // healthStore.execute(sampleQuery)
    }


    
    func checkHealthKitAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            print ("healthKit is available")
 
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
            ]
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
                if (error != nil) {
                    isHealthKitEnabled = success
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
