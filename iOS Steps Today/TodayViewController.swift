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
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
    
    @IBOutlet weak var stepsLabel2: UICountingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        
        stepsLabel2.font = stepsLabel2.font.withSize(48)
        stepsLabel2.format = "%d"
        // stepsLabel2.countFromZero(to: 0)
        stepsLabel2.textAlignment = .center

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
        let energyFormatter = EnergyFormatter()
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        getTodayStepCount (completion: { (steps) in
            let numberString = numberFormatter.string(from: steps! as NSNumber)
            
            if steps != -1.0 {
                OperationQueue.main.addOperation {
                    self.stepsLabel2.countFromCurrentValue(to: CGFloat(steps!), withDuration: 0.5)
                }
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
  
}
