//
//  TodayViewController.swift
//  iOS Steps Today
//
//  Created by Steve on 26/03/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        // Do any additional setup after loading the view from its nib.
        
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
        let numberFormatter = NumberFormatter()
        let numberString = numberFormatter.string(from: arc4random_uniform(10000) + 1 as NSNumber)
        textLabel.text = numberString
        print (numberString!)
    }
    
}
