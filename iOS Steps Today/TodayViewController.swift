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

import UICountingLabel

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var stepsLabel2: UICountingLabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
    let numberFormatter = NumberFormatter()
    
    var stepsToday: Double = 0.0
    var sevenDayStepAverage: Double = 100000.0
    var sevenDayStepAverageLastUpdated: Date = Date.distantPast
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        
        stepsLabel2.font = stepsLabel2.font.withSize(48)
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        stepsLabel2.formatBlock = {
            (value) in
            if (value == 0) {
                return ""
            } else {
                return (self.numberFormatter.string(from: value as NSNumber)!)
            }
        }
        stepsLabel2.textAlignment = .center
        
        stepsLabel2.isEnabled = false

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

    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print ("Screen tapped in Today Extension ", type (of: sender))
        
        let appURL = NSURL(string: "main-screen:/")
        self.extensionContext?.open(appURL! as URL, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
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
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        /*
        getTodayStepCount (completion: { (steps) in
            if steps != -1.0 {
                OperationQueue.main.addOperation {
                    self.stepsLabel2.countFromCurrentValue(to: CGFloat(steps!), withDuration: 0.5)
                }
            }
        })
         */
        
        getTodayStepCount (completion: { (steps) in
            if steps != -1.0 {
                OperationQueue.main.addOperation {
                    let numberString = self.numberFormatter.string(from: steps! as NSNumber)
                    self.stepsLabel.text = numberString!
                    
                    if (self.stepsToday > self.sevenDayStepAverage) {
                        self.stepsLabel.textColor = UIColor(red: 0, green: 0.25, blue: 0, alpha: 1.0) // pale green
                    } else {
                        self.stepsLabel.textColor = .black
                    }
                }
            }
        })
        
        // only update if not updated already today
        if (!cal.isDateInToday(sevenDayStepAverageLastUpdated)) {
            getSevenDayStepAverage (completion: { (averageSteps) in
                if averageSteps != -1.0 {
                    self.sevenDayStepAverage = averageSteps!
                    self.sevenDayStepAverageLastUpdated = Date()
                    OperationQueue.main.addOperation {
                        let numberString = self.numberFormatter.string(from: averageSteps! as NSNumber)
                        self.averageLabel.text = numberString!
                        
                        if (self.stepsToday > self.sevenDayStepAverage) {
                            self.stepsLabel.textColor = UIColor(red: 0, green: 0.25, blue: 0, alpha: 1.0) // pale green
                        } else {
                            self.stepsLabel.textColor = .black
                        }
                    }
                }
            })
        }
    }
    
    
    func checkHealthKitAuthorization() ->()
    {
        // Default to assuming that we're authorized
        var isHealthKitEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable() {
            print ("healthKit is available")
            
            let healthKitTypesToRead : Set = [
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.activeEnergyBurned)!,
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
    
    
    func getSevenDayStepAverage(completion:@escaping (Double?)->())
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
