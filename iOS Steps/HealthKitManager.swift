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


class HealthDataType {
    var timeStamp = Date()
    var data = 0.0
}


class HealthKitManager {
    
    let healthStore = HKHealthStore()
    private let numberFormatter = NumberFormatter()
    private let cal = Calendar.current
    
    init()
    {
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        checkHealthKitAuthorization()
    }
    
    let historyDays = 7
    
    private var earliestPermittedSampleDate: Date {
        return (healthStore.earliestPermittedSampleDate())
    }
    
    
    private var dateofBirthComponents: DateComponents {
        return try! healthStore.dateOfBirthComponents()
    }
    
    var dateOfBirth: Date {
        return (Calendar.current.date(from: dateofBirthComponents)!)
    }
    var dateOfNextBirthday: Date {
        var components = DateComponents ()
        components.day = dateofBirthComponents.day
        components.month = dateofBirthComponents.month
            
        return (cal.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, direction: .forward))!
    }
    var dateOfLastBirthday: Date {
        var components = DateComponents ()
        components.day = dateofBirthComponents.day
        components.month = dateofBirthComponents.month
        
        return (cal.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, direction: .backward))!
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

    
    var hourlySteps: [(timeStamp: Date, value: Double)] = []
    var hourlyStepsYesterday: [(timeStamp: Date, value: Double)] = []
    var stepsArray: [(timeStamp: Date, value: Double)] = []
    func updateHourlyStepsArray(completion:@escaping (Double?)->())
    {
        let startTime = Date()
        
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
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            let startTime = Date()
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -(self.historyDays + 1), to: endDate)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in  
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    
                    tempArray.append(timeStamp: date, value: steps)
                }
            }
            
            self.stepsArray = tempArray
            
            // filter today's steps
            self.hourlySteps = self.stepsArray.filter { self.cal.isDateInToday ($0.timeStamp) }
            // filter yesterday's steps
            self.hourlyStepsYesterday = self.stepsArray.filter { self.cal.isDateInYesterday($0.timeStamp) }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            // print ("updateHourlyStepsArray: \(self.stepsArray.count) in \(elapsedTime)")
            
            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    
    var activeEnergyArray: [(timeStamp: Date, value: Double)] = []
    func updateHourlyActiveEnergyArray(completion:@escaping (Double?)->())
    {
        let startTime = Date()
        
        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
        var interval = DateComponents()
        interval.hour = 1
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate!,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -(self.historyDays + 1), to: endDate)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let energy = quantity.doubleValue(for: HKUnit.calorie())
                    
                    tempArray.append(timeStamp: date, value: energy)
                }
            }
            
            self.activeEnergyArray = tempArray
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            // print ("updateHourlyActiveEnergyArray: \(self.activeEnergyArray.count) in \(elapsedTime)")

            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    var passiveEnergyArray: [(timeStamp: Date, value: Double)] = []
    func updateHourlyPassiveEnergyArray(completion:@escaping (Double?)->())
    {
        let startTime = Date()

        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
        var interval = DateComponents()
        interval.hour = 1
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate!,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -(self.historyDays + 1), to: endDate)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let energy = quantity.doubleValue(for: HKUnit.calorie())
                    
                    tempArray.append(timeStamp: date, value: energy)
                }
            }
            
            self.passiveEnergyArray = tempArray
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            // print ("updateHourlyPassiveEnergyArray: \(self.passiveEnergyArray.count) in \(elapsedTime)")

            completion (0.0)
        }
        healthStore.execute(query)
    }


    var activeCaloriesYesterday: Double = 0.0
    func getActiveCaloriesYesterday(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.calorie()
            let calories = quantity?.doubleValue(for: unit)
            
            if calories != nil {
                self.activeCaloriesYesterday = calories!
                completion(calories)
            } else {
                self.activeCaloriesYesterday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    var passiveCaloriesYesterday: Double = 0.0
    func getPassiveCaloriesYesterday(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
        
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -1, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.calorie()
            let calories = quantity?.doubleValue(for: unit)
            
            if calories != nil {
                self.passiveCaloriesYesterday = calories!
                completion(calories)
            } else {
                self.passiveCaloriesYesterday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    var activeCaloriesToday: Double = 0.0
    func getActiveCaloriesToday(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.calorie()
            let calories = quantity?.doubleValue(for: unit)
            
            if calories != nil {
                self.activeCaloriesToday = calories!
                completion(calories)
            } else {
                self.activeCaloriesToday = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    var passiveCaloriesToday: Double = 0.0
    func getPassiveCaloriesToday(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
        
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.calorie()
            let calories = quantity?.doubleValue(for: unit)
            
            if calories != nil {
                self.passiveCaloriesToday = calories!
                completion(calories)
            } else {
                self.passiveCaloriesToday = 0.0
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
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.flightsClimbed)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.basalEnergyBurned)!,
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
