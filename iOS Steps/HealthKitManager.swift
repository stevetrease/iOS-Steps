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
        dateOfBirthString = formatter.string(from: dateOfBirth)
        
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.year, .month, .day]
        ageFormatter.maximumUnitCount = 3
        ageString = ageFormatter.string(from: dateOfBirth, to: Date())!
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents ([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year

        let nextBirthday = calendar.date(byAdding: .year, value: age! + 1, to: dateOfBirth)
        
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.month, .day]
        ageFormatter.maximumUnitCount = 2

        nextBirthdayString = ageFormatter.string(from: Date(), to: nextBirthday!)!
    }
    
    
    var earliestPermittedSampleDate: Date = Date()
    var dateOfBirth: Date = Date()
    var dateOfBirthString: String = ""
    var nextBirthdayString: String = ""
    var ageString: String = ""
    var stepsToday: Double = 0.0
    var stepsTodayString: String = ""
    var flightsClimbedToday: Double = 0.0
    var flightsClimbedTodayString = ""
    var stepsYesterday: Double = 0.0
    var stepsYesterdayString: String = ""
    var flightsClimbedYesterday: Double = 0.0
    var flightsClimbedYesterdayString = ""

    
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
    
    func getYesterdayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        let cal = Calendar(identifier: .gregorian)
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            if results != nil {
                let quantity = results?.sumQuantity()
                let unit = HKUnit.count()
                let flights = quantity?.doubleValue(for: unit)
                
                self.flightsClimbedYesterday = flights!
                
                var pluralString = "s"
                if (flights != nil && Int(flights!) == 1) {
                    pluralString = ""
                }
                let numberFormatter = NumberFormatter()
                self.flightsClimbedYesterdayString = numberFormatter.string(from: flights! as NSNumber)! + " flight" + pluralString

                completion(flights)
            } else {
                print("getTodayStairCount: results are nil - returning zero flights")
                self.flightsClimbedYesterday = 0.0
                self.flightsClimbedYesterdayString = "0 flights"

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
    
    func getYesterdayStepCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let cal = Calendar(identifier: .gregorian)
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            if results != nil {
                let quantity = results?.sumQuantity()
                let unit = HKUnit.count()
                let steps = quantity?.doubleValue(for: unit)
                
                self.stepsYesterday = steps!
                
                var pluralString = "s"
                if (steps != nil && Int(steps!) == 1) {
                    pluralString = ""
                }
                let numberFormatter = NumberFormatter()
                self.stepsYesterdayString = numberFormatter.string(from: steps! as NSNumber)! + " step" + pluralString
                
                completion(steps)
            } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                self.stepsYesterday = 0.0
                self.stepsYesterdayString = "0 steps"

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
    

    func checkHealthKitAuthorization() ->()
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
        print (isHealthKitEnabled)
        // return isHealthKitEnabled
    }
}
