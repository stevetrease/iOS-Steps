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

let healthKitDidUpdateNotification1 = "healthKitDidUpdateNotification1"
let healthKitDidUpdateNotification2 = "healthKitDidUpdateNotification2"


class HealthKitManager {
    
    let historyDays = 7
    
    static let sharedInstance = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    private let numberFormatter = NumberFormatter()
    private let cal = Calendar.current
    
    init() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        checkHealthKitAuthorization()
    }
    

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
    
    
    var stepsToday: Double = 0.0
    func getTodayStepCount(completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
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
    func getYesterdayStepCount(completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
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
    
    
    var stepsAverage: Double = 0.0
    func getStepsAverage (completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -historyDays, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                self.stepsAverage = steps! / Double(self.historyDays)
                completion(steps! / Double(self.historyDays))
            } else {
                print("getStepsAverage: results are nil - returning zero steps")
                self.stepsAverage = 0.0
                completion(0.0)
            }
        }
        healthStore.execute(query)
    }

    
    var hourlySteps: [(timeStamp: Date, value: Double)] = []
    var hourlyStepsYesterday: [(timeStamp: Date, value: Double)] = []
    var stepsArray: [(timeStamp: Date, value: Double)] = []
    func updateHourlyStepsArray(completion:@escaping (Double?)->()) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        // longer interval, so less step periods initially
        var interval = DateComponents()
        if (hourlySteps.count == 0 ) {
            interval.minute = 60
        } else {
            interval.minute = 5
        }
        
        let anchorDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))
        
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
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = Date()
            let startDate = self.cal.date(byAdding: .day, value: -(self.historyDays + 1), to: endDate)
            
            var tempArray: [(timeStamp: Date, value: Double)] = []
            
            // statsCollection.enumerateStatistics(from: startDate!, to: endDate) { [unowned self] statistics, stop in
            
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { statistics, stop in
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
            
            // now call updates in viewControllers
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: healthKitDidUpdateNotification1), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: healthKitDidUpdateNotification2), object: nil)
            
            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    
    var workoutData: [HKWorkout] = []
    func getWorkouts (completion:@escaping (Double?)->()) {
        //   Define the sample type
        let sampleType = HKObjectType.workoutType()
        
        let endDate = Date()
        let startDate =  cal.date(byAdding: .day, value: -historyDays * 5, to: endDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let limit = 0
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [ sortDescriptor ]) { query, results, error in
            if let results = results {
                
                self.workoutData = []
                
                for result in results {
                    if let workout = result as? HKWorkout {
                        self.workoutData.append(workout)
                    }
                }
            }
            else {
                print ("No results were returned, check the error")
            }
            completion (0.0)
        }
        healthStore.execute(query)
    }
    
    
    func workoutTypeIcon (_ type: HKWorkoutActivityType) -> String {
        switch type {
        case HKWorkoutActivityType.cycling:
            return ("🚴‍♂️")
        case HKWorkoutActivityType.running:
            return ("🏃")
        case HKWorkoutActivityType.walking:
            return ("🚶")
        default:
            return ("?")
        }
    }


    func checkHealthKitAuthorization() ->() {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.workoutType(),
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
