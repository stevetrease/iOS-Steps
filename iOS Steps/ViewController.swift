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
    @IBOutlet weak var chartView: CombinedChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(#file) - \(#function)")
        
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
        chartView.leftAxis.axisMinimum = 0.0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.chartDescription?.text = ""
        
        chartView.drawBordersEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
        chartView.xAxis.granularity = 1.0
        chartView.xAxis.granularityEnabled = true
        
        drawScreen()
    }
    
    
    func drawScreenHKObserverQuery () {
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print("\(#file) - \(#function)")
        
        let startTime = Date()
        let generator = UIImpactFeedbackGenerator(style: .light)
        // watchConnectivityHandler?.sendMessage (message: "Hello")
        
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
        
        healthKitManager.updateHourlyStepsArray(completion: { (x) in
            OperationQueue.main.addOperation {
                var elapsed = Date().timeIntervalSince(startTime)
                print ("updateStepsArray call time = \(elapsed)")
                
                var hourlyDataEntries: [BarChartDataEntry] = []
                var line1Data: [ChartDataEntry] = []
                var line2Data: [ChartDataEntry] = []
                
                var firstHour = 24.0
                var lastHour = 0.0
                
                var accumulator1 = 0.0
                for i in 0..<healthKitManager.hourlySteps.count {
                    let cal = Calendar.current
                    let d = healthKitManager.hourlySteps[i].date
                    let components = cal.dateComponents ([.hour], from: d)
                    let hour = Double(components.hour!)
                    let value = healthKitManager.hourlySteps[i].value
                    
                    if (hour < firstHour) {
                        firstHour = hour
                    }
                    if (hour > lastHour) {
                        lastHour = hour
                    }
                
                    accumulator1 = accumulator1 + value
                    
                    let hourlyDataEntry = BarChartDataEntry(x: hour, y: value)
                    hourlyDataEntries.append(hourlyDataEntry)
                    
                    let line1DataPoint = ChartDataEntry (x: hour, y: Double (accumulator1))
                    line1Data.append (line1DataPoint)
                }
                
                var accumulator2 = 0.0
                for i in 0..<healthKitManager.hourlyStepsYesterday.count {
                    let cal = Calendar.current
                    let d = healthKitManager.hourlyStepsYesterday[i].date
                    let components = cal.dateComponents ([.hour], from: d)
                    let hour = Double(components.hour!)
                    let value = healthKitManager.hourlyStepsYesterday[i].value
                    
                    if (hour < firstHour) {
                        firstHour = hour
                    }
                    if (hour > lastHour) {
                        
                        lastHour = hour
                    }
                    
                    accumulator2 = accumulator2 + value
                    
                    let line2DataPoint = ChartDataEntry (x: hour, y: Double (accumulator2))
                    line2Data.append (line2DataPoint)
                }
                
                let barDataSet = BarChartDataSet(values: hourlyDataEntries, label: "")
                let lineDataSet1 = LineChartDataSet(values: line1Data, label: "Today")
                let lineDataSet2 = LineChartDataSet(values: line2Data, label: "Yesterday")
                
                barDataSet.colors = [UIColor.darkText]
                lineDataSet1.colors = [UIColor.darkText]
                lineDataSet1.drawCirclesEnabled = false
                lineDataSet1.lineWidth = 3
                lineDataSet2.colors = [UIColor.lightGray]
                lineDataSet2.drawCirclesEnabled = false
                lineDataSet2.lineWidth = 2
                
                let barData = BarChartData(dataSets: [barDataSet])
                let lineData = LineChartData (dataSets: [lineDataSet2, lineDataSet1])
                
                lineData.setDrawValues(false)
                
                let data: CombinedChartData = CombinedChartData()
                data.barData = barData
                data.lineData = lineData
                
                
                self.chartView.xAxis.axisMinimum = firstHour - 0.5
                self.chartView.xAxis.axisMaximum = lastHour + 0.5

                self.chartView.data = data
                self.chartView.data?.notifyDataChanged()
                self.chartView.notifyDataSetChanged()
                
                elapsed = Date().timeIntervalSince(startTime)
                print ("updateStepsArray finished =  \(elapsed)")
            }
        })
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print ("\(#file) - \(#function)")
        print ("Screen tapped ", type (of: sender))
        
        drawScreen()
    }

    
    @IBAction func unWindToViewControllerSegue (segue: UIStoryboardSegue) {}
    
    
    override func didReceiveMemoryWarning() {
        print("\(#file) - \(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
