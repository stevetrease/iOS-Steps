//
//  BackViewController3.swift
//  iOS Steps
//
//  Created by Steve on 18/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import Foundation

import UIKit
import Foundation
import HealthKit
import Charts



class BackViewController3: UIViewController {
    
    @IBOutlet weak var chartView3: CombinedChartView!
    
    private let cal = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        chartView3.legend.enabled = true
        chartView3.xAxis.drawLabelsEnabled = true
        chartView3.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView3.xAxis.drawGridLinesEnabled = false
        chartView3.leftAxis.axisMinimum = 0
        chartView3.leftAxis.drawGridLinesEnabled = false
        chartView3.rightAxis.drawLabelsEnabled = false
        chartView3.leftAxis.drawLabelsEnabled = true
        chartView3.chartDescription?.text = ""
        
        chartView3.drawBordersEnabled = false
        chartView3.leftAxis.drawAxisLineEnabled = false
        chartView3.rightAxis.drawAxisLineEnabled = false
        chartView3.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
        chartView3.xAxis.granularity = 1.0
        chartView3.xAxis.granularityEnabled = true
        
        drawScreen()
    }
    
    
    func viewWillAppear() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen () {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        healthKitManager.updateHourlyStepsArray(completion: { (steps) in
            OperationQueue.main.addOperation {
                print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
                
                var firstHour = 24.0
                var lastHour = 0.0
                var lines: [LineChartDataSet] = []
                
                
                for day in -healthKitManager.historyDays...0 {
                    let filterDay = self.cal.date(byAdding: .day, value: day, to: self.cal.startOfDay(for: Date()))
                    
                    var dailySteps = healthKitManager.stepsArray.filter { self.cal.startOfDay(for: $0.timeStamp) == filterDay }
                    
                    var dailyLineDataEntries: [BarChartDataEntry] = []
                    
                    var accumulator = 0.0
                    for i in 0..<dailySteps.count {
                        let cal = Calendar.current
                        let d = dailySteps[i].timeStamp
                        let components = cal.dateComponents ([.hour], from: d)
                        let hour = Double(components.hour!)
                        
                        accumulator = accumulator + dailySteps[i].value
                        let value = accumulator
                        
                        if (hour < firstHour) {
                            firstHour = hour
                        }
                        if (hour > lastHour) {
                            lastHour = hour
                        }
                        
                        let dailyLineDataEntry = BarChartDataEntry(x: hour, y: value)
                        dailyLineDataEntries.append(dailyLineDataEntry)
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E"
                    var dayString = formatter.string (from: filterDay!)

                    if (day == 0) {
                        dayString = "Today"
                    }
         
                    let lineDataSet = LineChartDataSet(values: dailyLineDataEntries, label: dayString)
                    
                    let colourFraction = 1.0 / Double(healthKitManager.historyDays + 1)
                    let whiteValue = (Double(day) * colourFraction * -1.0)
                    
                    lineDataSet.colors = [UIColor(white: CGFloat(whiteValue), alpha: 1.0)]
                    lineDataSet.drawCirclesEnabled = false
                    
                    if (day == 0) {
                        lineDataSet.lineWidth = 3
                    } else {
                        lineDataSet.lineWidth = 1
                    }
                    
                    lines.append(lineDataSet)
                }
                
                let data: CombinedChartData = CombinedChartData()
                let lineData = LineChartData (dataSets: lines)
         
                data.lineData = lineData
                
                self.chartView3.data = data
                self.chartView3.data?.notifyDataChanged()
                self.chartView3.notifyDataSetChanged()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print ("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
