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
    @IBOutlet weak var refreshButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("viewDidLoad")
        todayStepCountLabel.text = " "
        todayFlightClimbedLabel.text = " "
        
        drawScreen()
    }
    
    
    func drawScreen () {
        
        let dateOfBirth = HealthKitManager().getDateOfBirth()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        
        let dateString = formatter.string(from: dateOfBirth)
        dateOfBirthLabel.text = dateString

        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
        ageFormatter.allowedUnits = [.year, .month, .day]
        ageFormatter.maximumUnitCount = 3
        
        let ageString = ageFormatter.string(from: dateOfBirth, to: Date())
        ageLabel.text = ageString

        HealthKitManager().getTodayStepCount(completion: { (steps) in
            let numberFormatter = NumberFormatter()
            let stepsString = numberFormatter.string(from: steps! as NSNumber)
            
            var pluralString = "s"
            if (steps != nil && Int(steps!) == 1) {
                pluralString = ""
            }
            
            self.todayStepCountLabel.text = stepsString! + " step"  + pluralString
        })
        
        HealthKitManager().getTodayFlightsClimbedCount(completion: { (flights) in
            let numberFormatter = NumberFormatter()
            let flightsString = numberFormatter.string(from: flights! as NSNumber)
            
            var pluralString = "s"
            if (flights != nil && Int(flights!) == 1) {
                pluralString = ""
            }
            
            self.todayFlightClimbedLabel.text = flightsString! + " flight" + pluralString
        })

    }
    
    
    @IBAction func actionTriggered(sender: AnyObject) {
        // print ("Button pressed")
        drawScreen()
    }
    
    
    override func didReceiveMemoryWarning() {
        print ("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}







