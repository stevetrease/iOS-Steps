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
import Charts



class ViewController: UIViewController {

    @IBOutlet weak var todayStepCountLabel: UILabel!
    @IBOutlet weak var todayFlightClimbedLabel: UILabel!
    @IBOutlet weak var yesterdayStepCountLabel: UILabel!
    @IBOutlet weak var yesterdayFlightClimbedLabel: UILabel!
    @IBOutlet weak var chartVew: BarChartView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("viewDidLoad")
        
        todayStepCountLabel.text = " "
        todayFlightClimbedLabel.text = " "
        yesterdayStepCountLabel.text = " "
        yesterdayFlightClimbedLabel.text = " "
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.myViewController = self
        
        chartVew.legend.enabled = false
        chartVew.xAxis.drawLabelsEnabled = true
        chartVew.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartVew.xAxis.drawGridLinesEnabled = false
        chartVew.leftAxis.drawGridLinesEnabled = false
        chartVew.rightAxis.drawLabelsEnabled = false
        chartVew.leftAxis.drawLabelsEnabled = false
        chartVew.descriptionText = ""
        chartVew.drawBordersEnabled = false
        chartVew.leftAxis.drawAxisLineEnabled = false
        chartVew.rightAxis.drawAxisLineEnabled = false
        
        chartVew.animate(xAxisDuration: 0.2, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print ("drawScreen")

        let generator = UIImpactFeedbackGenerator(style: .light)

        healthKitManager.getTodayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                self.todayStepCountLabel.text = healthKitManager.stepsTodayString + " today"
            }
            generator.impactOccurred()
        })
        
        healthKitManager.getYesterdayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                self.yesterdayStepCountLabel.text = healthKitManager.stepsYesterdayString + " yesterday"
            }
        })
        
        healthKitManager.getTodayFlightsClimbedCount (completion: { (flights) in
            OperationQueue.main.addOperation {
                 self.todayFlightClimbedLabel.text = healthKitManager.flightsClimbedTodayString + " today"
            }
            generator.impactOccurred()
        })

        healthKitManager.getYesterdayFlightsClimbedCount( completion: { (flights) in
            OperationQueue.main.addOperation {
                self.yesterdayFlightClimbedLabel.text = healthKitManager.flightsClimbedYesterdayString + " yesterday"
            }
        })
        
        healthKitManager.getHourlyTodaySteps (completion: { (steps) in
            OperationQueue.main.addOperation {
                print ("healthKitManager.getTodaysHourlySteps \(healthKitManager.hourlySteps.count)")
                
                var x: [Double] = []
                var y: [Double] = []
                
                for i in 0..<healthKitManager.hourlySteps.count {
                    let cal = Calendar.current
                    let d = healthKitManager.hourlySteps[i].date
                    let components = cal.dateComponents ([.hour], from: d)
                    let hour = Double(components.hour!)
                    x.append(hour)
                    y.append(healthKitManager.hourlySteps[i].value)
                    // y.append(Double(arc4random_uniform(1000) + 1))
                }
                self.setChart(dates: x, values: y)
            }
        })
        
        healthKitManager.getHourlyYesterdaySteps (completion: { (steps) in
            OperationQueue.main.addOperation {
                print ("healthKitManager.getYesterdaysHourlySteps \(healthKitManager.hourlyStepsYesterday.count)")
            }
        })

    }


    func setChart(dates: [Double], values: [Double]) {

        print ("setChart")
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dates.count {
           let dataEntry = BarChartDataEntry(x: dates[i], y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartVew.data = chartData
        chartVew.data?.notifyDataChanged()
        chartVew.notifyDataSetChanged()
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







