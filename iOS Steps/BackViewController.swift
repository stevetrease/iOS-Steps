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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("BackViewController - viewDidLoad")
        
        dateOfBirthLabel.text = healthKitManager.dateOfBirthSting
        ageLabel.text = healthKitManager.ageString
        
    }
    
    
    override func didReceiveMemoryWarning() {
        print ("BackViewController - didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
