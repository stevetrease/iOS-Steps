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
    @IBOutlet weak var chartView: BarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("viewDidLoad")
        
        todayStepCountLabel.text = " "
        todayFlightClimbedLabel.text = " "
        yesterdayStepCountLabel.text = " "
        yesterdayFlightClimbedLabel.text = " "
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.myViewController = self
        
        chartView.legend.enabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.descriptionText = ""
        chartView.drawBordersEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.animate(xAxisDuration: 0.2, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
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
                self.chartView.data = chartData
                self.chartView.data?.notifyDataChanged()
                self.chartView.notifyDataSetChanged()
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







