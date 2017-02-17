//
//  ViewController.swift
//  iOS Steps
//
//  Created by Steve on 29/01/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Foundation
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var todayStepCountLabel: UILabel!
    @IBOutlet weak var todayFlightClimbedLabel: UILabel!
    @IBOutlet weak var yesterdayStepCountLabel: UILabel!
    @IBOutlet weak var yesterdayFlightClimbedLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("viewDidLoad")
        
        todayStepCountLabel.text = " "
        todayFlightClimbedLabel.text = " "
        yesterdayStepCountLabel.text = " "
        yesterdayFlightClimbedLabel.text = " "
        
        dateOfBirthLabel.text = healthKitManager.dateOfBirthSting
        ageLabel.text = healthKitManager.ageString
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.myViewController = self
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print ("drawScreen")
        
        healthKitManager.getTodayStepCount(completion: { (steps) in
            self.todayStepCountLabel.text = healthKitManager.stepsTodayString + " today"
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        })
        
        healthKitManager.getYesterdayStepCount(completion: { (steps) in
            self.yesterdayStepCountLabel.text = healthKitManager.stepsYesterdayString + " yesterday"
        })
        
        healthKitManager.getTodayFlightsClimbedCount(completion: { (flights) in
            self.todayFlightClimbedLabel.text = healthKitManager.flightsClimbedTodayString + " today"
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        })

        healthKitManager.getYesterdayFlightsClimbedCount(completion: { (flights) in
            self.yesterdayFlightClimbedLabel.text = healthKitManager.flightsClimbedYesterdayString + " yesterday"
        })
    }
    
    
    @IBAction func actionTriggered(sender: AnyObject) {
        print ("Button pressed")
        drawScreen()
    }
    
    
    @IBAction func unWindToViewControllerSegue (segue: UIStoryboardSegue) {}
    
    
    override func didReceiveMemoryWarning() {
        print ("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}







