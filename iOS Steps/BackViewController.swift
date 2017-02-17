//
//  BackViewController.swift
//  iOS Steps
//
//  Created by Steve on 17/02/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Foundation
import HealthKit



class BackViewController: UIViewController {
    
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nextBirthdayLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("BackViewController - viewDidLoad")
        
        dateOfBirthLabel.text = healthKitManager.dateOfBirthString
        ageLabel.text = healthKitManager.ageString
        nextBirthdayLabel.text = healthKitManager.nextBirthdayString
        
    }
    
    
    override func didReceiveMemoryWarning() {
        print ("BackViewController - didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}