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
    @IBOutlet weak var chartVew2: CombinedChartView!


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
        
        chartVew2.legend.enabled = false
        chartVew2.xAxis.drawLabelsEnabled = true
        chartVew2.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartVew2.xAxis.drawGridLinesEnabled = false
        chartVew2.leftAxis.drawGridLinesEnabled = false
        chartVew2.rightAxis.drawLabelsEnabled = false
        chartVew2.leftAxis.drawLabelsEnabled = false
        chartVew2.descriptionText = ""
        chartVew2.drawBordersEnabled = false
        chartVew2.leftAxis.drawAxisLineEnabled = false
        chartVew2.rightAxis.drawAxisLineEnabled = false
        chartVew2.animate(xAxisDuration: 0.2, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
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
                
                var hourlyDataEntries: [BarChartDataEntry] = []
                
                var accumulator = 0.0
                for i in 0..<healthKitManager.hourlySteps.count {
                    let cal = Calendar.current
                    let d = healthKitManager.hourlySteps[i].date
                    let components = cal.dateComponents ([.hour], from: d)
                    let hour = Double(components.hour!)
                    let value = healthKitManager.hourlySteps[i].value
                    accumulator = accumulator + value
                    // let dataEntry = BarChartDataEntry(x: hour, y: accumulator)
                    let hourlyDataEntry = BarChartDataEntry(x: hour, y: value)
                    hourlyDataEntries.append(hourlyDataEntry)
                }
                let chartDataSet = BarChartDataSet(values: hourlyDataEntries, label: "")
                let chartData = BarChartData(dataSet: chartDataSet)
                self.chartVew.data = chartData
                self.chartVew.data?.notifyDataChanged()
                self.chartVew.notifyDataSetChanged()
            }
        })
        
        healthKitManager.getHourlyYesterdaySteps (completion: { (steps) in
            OperationQueue.main.addOperation {
                print ("healthKitManager.getYesterdaysHourlySteps \(healthKitManager.hourlyStepsYesterday.count)")
            }
        })
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







