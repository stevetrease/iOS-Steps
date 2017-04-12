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
    private let numberFormatter = NumberFormatter()
    private let cal = Calendar.current
    
    init()
    {
        // print ("HealthKitManager.init")
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        checkHealthKitAuthorization()
    }
    
    let historyDays = 7
    
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

    
    var flightsClimbedToday: Double = 0.0
    var flightsClimbedTodayString: String {
        if (Int(flightsClimbedToday) != 1) {
            return (numberFormatter.string(from: flightsClimbedToday as NSNumber)! + " flights")
        } else {
            return "1 flight"
        }
    }
    func getTodayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
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
    
    
    var flightsClimbedYesterday: Double = 0.0
    var flightsClimbedYesterdayString: String {
        if (Int(flightsClimbedYesterday) != 1) {
            return (numberFormatter.string(from: flightsClimbedYesterday as NSNumber)! + " flights")
        } else {
            return "1 flight"
        }
    }
    func getYesterdayFlightsClimbedCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
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

    
    var stepsToday: Double = 0.0
    var stepsTodayString: String {
        if (Int(stepsToday) != 1) {
            return (numberFormatter.string(from: stepsToday as NSNumber)! + " steps")
        } else {
            return "1 step"
        }
    }
    func getTodayStepCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
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
    

    var stepsYesterday: Double = 0.0
    var stepsYesterdayString: String {
        if (Int(stepsYesterday) != 1) {
            return (numberFormatter.string(from: stepsYesterday as NSNumber)! + " steps")
        } else {
            return "1 step"
        }
    }
    func getYesterdayStepCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
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

    
    var hourlySteps: [(date: Date, value: Double)] = []
    var hourlyStepsYesterday: [(date: Date, value: Double)] = []
    var stepsArray: [(date: Date, value: Double)] = []
    private var stepsArrayLastUpdated: Date = Date.distantPast
    func updateHourlyStepsArray(completion:@escaping (Double?)->())
    {
        if (cal.startOfDay(for: Date()) == cal.startOfDay(for: self.stepsArrayLastUpdated)) {
            completion (0.0)
        }
        self.stepsArrayLastUpdated = Date ()
        
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
            
            print ("query: updateStepsArray")
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -self.historyDays, to: endDate)
            
            self.stepsArray = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in  
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    self.stepsArray.append(date: date, value: steps)
                }
            }
            print ("steps array length: \(self.stepsArray.count)")
            
            // filter today's steps
            self.hourlySteps = self.stepsArray.filter { self.cal.startOfDay(for: $0.date) == self.cal.startOfDay(for: Date()) }
            // filter yesterday's steps
            self.hourlyStepsYesterday = self.stepsArray.filter { self.cal.startOfDay(for: $0.date) == self.cal.date(byAdding: .day, value: -1, to: self.cal.startOfDay(for: Date())) }

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
