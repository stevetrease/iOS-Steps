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
    let numberFormatter = NumberFormatter()
    
    let cal = Calendar.current
    
    init()
    {
        // print ("HealthKitManager.init")
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        checkHealthKitAuthorization()
    }
    
    
    var earliestPermittedSampleDate: Date {
        return (healthStore.earliestPermittedSampleDate())
    }
    
    var dateOfBirth: Date {
        let dateOfBirthComponents = try? healthStore.dateOfBirthComponents()
        return (Calendar.current.date(from: dateOfBirthComponents!)!)
    }
    
    var dateOfBirthString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return (formatter.string(from: dateOfBirth))
    }
    
    var nextBirthdayString: String {
        let ageComponents = cal.dateComponents ([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year
        let nextBirthday = cal.date(byAdding: .year, value: age! + 1, to: dateOfBirth)
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.month, .day]
        ageFormatter.maximumUnitCount = 2
        return (ageFormatter.string(from: Date(), to: nextBirthday!)!)
    }
    
    var nextBirthdayDaysString: String {
        let ageComponents = cal.dateComponents ([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year
        let nextBirthday = cal.date(byAdding: .year, value: age! + 1, to: dateOfBirth)
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.day]
        ageFormatter.maximumUnitCount = 1
        return (ageFormatter.string(from: Date(), to: nextBirthday!)!)
    }

    
    var ageString: String {
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.year, .month, .day]
        ageFormatter.maximumUnitCount = 3
        return (ageFormatter.string(from: dateOfBirth, to: Date())!)
    }

    var stepsToday: Double = 0.0
    var stepsTodayString: String {
        if (Int(stepsToday) != 1) {
            return (numberFormatter.string(from: stepsToday as NSNumber)! + " steps")
        } else {
            return "1 step"
        }
    }

    var stepsYesterday: Double = 0.0
    var stepsYesterdayString: String {
        if (Int(stepsYesterday) != 1) {
            return (numberFormatter.string(from: stepsYesterday as NSNumber)! + " steps")
        } else {
            return "1 step"
        }
    }

    var flightsClimbedToday: Double = 0.0
    var flightsClimbedTodayString: String {
        if (Int(flightsClimbedToday) != 1) {
            return (numberFormatter.string(from: flightsClimbedToday as NSNumber)! + " flights")
        } else {
            return "1 flight"
        }
    }
    
    var flightsClimbedYesterday: Double = 0.0
    var flightsClimbedYesterdayString: String {
        if (Int(flightsClimbedYesterday) != 1) {
            return (numberFormatter.string(from: flightsClimbedYesterday as NSNumber)! + " flights")
        } else {
            return "1 flight"
        }
    }
    
    var hourlySteps: [(date: Date, value: Double)] = []
    var hourlyStepsYesterday: [(date: Date, value: Double)] = []
    
    
    
    func getTodayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        // let cal = Calendar(identifier: .gregorian)
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            // print ("query: getTodayFlightsClimbedCount")
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let flights = quantity?.doubleValue(for: unit)

            if flights != nil {
                self.flightsClimbedToday = flights!
                completion(flights)
            } else {
                print("getTodayStairCount: results are nil - returning zero flights")
                self.flightsClimbedToday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    func getYesterdayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        // let cal = Calendar(identifier: .gregorian)
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            // print ("query: getYesterdayFlightsClimbedCount")
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let flights = quantity?.doubleValue(for: unit)

            if flights != nil {
                self.flightsClimbedYesterday = flights!
                 completion(flights)
            } else {
                print("getTodayStairCount: results are nil - returning zero flights")
                self.flightsClimbedYesterday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }

    
    func getTodayStepCount(completion:@escaping (Double?)->())
    {

        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // let cal = Calendar(identifier: .gregorian)
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            // print ("query: getTodayStepCount")
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                self.stepsToday = steps!
                completion(steps)
             } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                self.stepsToday = 0.0
                completion(0.0)
             }
        }
        healthStore.execute(query)
    }
    
    
    func getYesterdayStepCount(completion:@escaping (Double?)->())
    {
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // let cal = Calendar(identifier: .gregorian)
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            // print ("query: getYesterdayStepCount")
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)

            if steps != nil {
                self.stepsYesterday = steps!
                completion(steps)
            } else {
                print("getTodayStepCount: results are nil - returning zero steps")
                self.stepsYesterday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
 
    func getHourlyTodaySteps(completion:@escaping (Double?)->())
    {
        // let cal = Calendar.current
        let anchorDate = cal.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.hour = 1
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            // print ("query: getHourlyTodaySteps")
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let startDate = self.cal.startOfDay(for: Date())
            let endDate = Date()
            
            self.hourlySteps = []
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    self.hourlySteps.append(date: date, value: steps)
                }
            }
            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    
    private var hourlyYesterdayStepsLastUpdated: Date = Date.distantPast
    func getHourlyYesterdaySteps(completion:@escaping (Double?)->())
    {
        // let cal = Calendar(identifier: .gregorian)
        
        if (cal.startOfDay(for: Date()) == cal.startOfDay(for: self.hourlyYesterdayStepsLastUpdated)) {
                completion (0.0)
        }
        self.hourlyYesterdayStepsLastUpdated = Date ()
        
        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
        var interval = DateComponents()
        interval.hour = 1
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate!,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            // let cal = Calendar(identifier: .gregorian)
            
            // print ("query: getHourlyYesterdaySteps")
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = self.cal.startOfDay(for: Date())
            let startDate = self.cal.date(byAdding: .day, value: -1, to: endDate)

            self.hourlyStepsYesterday = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    self.hourlyStepsYesterday.append(date: date, value: steps)
                }
            }
            completion (0.0)
        }
        healthStore.execute(query)
    }



    func checkHealthKitAuthorization() ->()
    {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
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
        print ("HeakthKit available? ", isHealthKitEnabled)
    }
}
