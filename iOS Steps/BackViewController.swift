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
    @IBOutlet weak var nextBirthdayDaysLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func viewWillAppear() {
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen() {
        print("\(#file) - \(#function)")
        
        dateOfBirthLabel.text = healthKitManager.dateOfBirthString
        ageLabel.text = healthKitManager.ageString
        nextBirthdayLabel.text = healthKitManager.nextBirthdayString
        nextBirthdayDaysLabel.text = healthKitManager.nextBirthdayDaysString
    }
    
    
    override func didReceiveMemoryWarning() {
        print("\(#file) - \(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
