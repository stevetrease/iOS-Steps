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
    
    let cal = Calendar.current
    
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
        // let dateOfBirth = Date()
        let nextBirthday = healthKitManager.dateOfNextBirthday
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirth)
        
        let ageFormatter = DateComponentsFormatter()
        ageFormatter.unitsStyle = .full

        let components1 = cal.dateComponents( [.month, .day], from: dateOfBirth)
        let components2 = cal.dateComponents( [.month, .day], from: Date())
    
        if components1 == components2 {
            timeToNextBirthdayDaysLabel.text = "Happy birthday"
            nextBirthdayLabel.isHidden = true
        } else {
            ageFormatter.allowedUnits = [.day]
            timeToNextBirthdayDaysLabel.text = ageFormatter.string(from: Date(), to: nextBirthday)
            nextBirthdayLabel.isHidden = false
            nextBirthdayLabel.text = dateFormatter.string(from: nextBirthday)
        }
            
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
