//
//  BackViewController2.swift
//  iOS Steps
//
//  Created by Steve on 11/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Foundation
import HealthKit



class BackViewController2: UIViewController {
    
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nextBirthdayLabel: UILabel!
    @IBOutlet weak var nextBirthdayDaysLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("BackViewController2 - viewDidLoad")
        
        dateOfBirthLabel.text = healthKitManager.dateOfBirthString
        ageLabel.text = healthKitManager.ageString
        nextBirthdayLabel.text = healthKitManager.nextBirthdayString
        nextBirthdayDaysLabel.text = healthKitManager.nextBirthdayDaysString
    }
    
    
    override func didReceiveMemoryWarning() {
        print ("BackViewController2 - didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
