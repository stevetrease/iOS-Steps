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
    @IBOutlet weak var timeToNextBirthdayDaysLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        drawScreen()
    }
    
    
    func viewWillAppear() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        let dateOfBirth = healthKitManager.dateOfBirth
        let nextBirthday = healthKitManager.dateOfNextBirthday
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirth)
        nextBirthdayLabel.text = dateFormatter.string(from: nextBirthday)

        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full
    
        ageFormatter.allowedUnits = [.day]
        timeToNextBirthdayDaysLabel.text =  ageFormatter.string(from: Date(), to: nextBirthday)
        
        ageFormatter.allowedUnits = [.year, .month, .day]
        ageFormatter.maximumUnitCount = 3
        ageLabel.text = ageFormatter.string(from: dateOfBirth, to: Date())
    }
    
    
    override func didReceiveMemoryWarning() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
