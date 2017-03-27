//
//  TodayViewController.swift
//  iOS Steps Today
//
//  Created by Steve on 26/03/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import NotificationCenter
import HealthKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let healthStore = HKHealthStore()
    var stepsToday: Double = 0.0
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        
        stepsLabel.text = "--"
        checkHealthKitAuthorization()
        
        updateView ()
    }
    
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print ("viewDidAppear")
        
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        print ("widgetPerformUpdate")
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        OperationQueue.main.addOperation {
            self.updateView()
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func updateView () {
        getTodayStepCount (completion: { (steps) in
            print ("getTodayStepCount")
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let numberString = numberFormatter.string(from: steps! as NSNumber)
            print ("numberString ", numberString!)
            
            OperationQueue.main.addOperation {
                self.stepsLabel.text = numberString!
            }
        })
    }
    
    
    func checkHealthKitAuthorization() ->()
    {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            print ("healthKit is available")
            
            let healthKitTypesToRead : Set = [
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
            print ("query: getTodayStepCount")
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
  
}
