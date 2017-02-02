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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("viewDidLoad")
        
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

        todayStepCountLabel.text = " "
        HealthKitManager().getTodayStepCount(completion: { (steps) in
            let numberFormatter = NumberFormatter()
            let stepsString = numberFormatter.string(from: steps! as NSNumber)
            
            var pluralString = "s"
            
            self.todayStepCountLabel.text = stepsString! + " step"  + pluralString
        })
        
        todayFlightClimbedLabel.text = " "
        HealthKitManager().getTodayFlightsClimbedCount(completion: { (flights) in
            let numberFormatter = NumberFormatter()
            let flightsString = numberFormatter.string(from: flights! as NSNumber)
            
            var pluralString = "s"

            self.todayFlightClimbedLabel.text = flightsString! + " flight" + pluralString
        })

        
    }
    
    
    override func didReceiveMemoryWarning() {
        print ("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}







