//
//  InterfaceController.swift
//  iOS Steps Watch Extension
//
//  Created by Steve on 05/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

// class InterfaceController: WKInterfaceController, WCSessionDelegate {
class InterfaceController: WKInterfaceController {

    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var averageLabel: WKInterfaceLabel!
    
    
    let healthStore = HKHealthStore()
    var session : WCSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            stepsLabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            stepsLabel.setText("no quantity")
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.stepsLabel.setText("not allowed")
            }
        }

        self.updateView()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print ("didActivate")
        
        self.updateView()
    }
    
    
    func updateView () {
        getTodayStepCount (completion: { (steps) in
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let numberString = numberFormatter.string(from: steps! as NSNumber)
            
            if steps != -1.0 {
                WKInterfaceDevice.current().play(.click)
                OperationQueue.main.addOperation {
                    self.stepsLabel.setText(numberString!)
                }
            }
        })
        
        getSevenDayStepCount (completion: { (steps) in
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let numberString = numberFormatter.string(from: steps! as NSNumber)
            
            if steps != -1.0 {
                OperationQueue.main.addOperation {
                    self.averageLabel.setText(numberString!)
                }
            }
        })
    }

    
    func getTodayStepCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let cal = Calendar.current
        let startDate = cal.startOfDay(for: Date())
        let endDate = Date()
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                completion(steps)
            } else {
                print("getTodayStepCount: results are nil - returning nil steps")
                completion(-1.0)
            }
        }
        healthStore.execute(query)
    }
    
    
    func getSevenDayStepCount(completion:@escaping (Double?)->())
    {
        //   Define the sample type
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let cal = Calendar.current
        let endDate = cal.startOfDay(for: Date())
        let startDate =  cal.date(byAdding: .day, value: -7, to: endDate)
        
        //  Set the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: type!, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, results, error in
            let quantity = results?.sumQuantity()
            let unit = HKUnit.count()
            let steps = quantity?.doubleValue(for: unit)
            
            if steps != nil {
                completion(steps! / 7.0)
            } else {
                print("getStepsAverage: results are nil - returning zero steps")
                completion(-1.0)
            }
        }
        healthStore.execute(query)
    }
}
