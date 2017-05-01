//
//  BackViewController2.swift
//  iOS Steps
//
//  Created by Steve on 11/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Foundation
import HealthKit
import Charts



class BackViewController2: UIViewController {

    @IBOutlet weak var chartView2: CombinedChartView!

    private let cal = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        chartView2.legend.enabled = false
        chartView2.xAxis.drawLabelsEnabled = true
        chartView2.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView2.xAxis.drawGridLinesEnabled = false
        chartView2.leftAxis.axisMinimum = 0
        chartView2.leftAxis.drawGridLinesEnabled = false
        chartView2.rightAxis.drawLabelsEnabled = false
        chartView2.leftAxis.drawLabelsEnabled = true
        chartView2.chartDescription?.text = ""
        
        chartView2.drawBordersEnabled = false
        chartView2.leftAxis.drawAxisLineEnabled = false
        chartView2.rightAxis.drawAxisLineEnabled = false
        chartView2.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
        chartView2.xAxis.granularity = 1.0
        chartView2.xAxis.granularityEnabled = true
        
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
                
                var dailyStepDataEntries: [BarChartDataEntry] = []
                var xLabels: [String] = []
                
                for day in -healthKitManager.historyDays...0 {
                    let filterDay = self.cal.date(byAdding: .day, value: day, to: self.cal.startOfDay(for: Date()))
                    
                    let stepsForDay: [(date: Date, value: Double)] = healthKitManager.stepsArray.filter { self.cal.startOfDay(for: $0.date) == filterDay }
                
                    var accumulator = 0.0
                    for hour in stepsForDay {
                        let value = hour.value
                        accumulator = accumulator + value
                    }

                    let dailyStepEntry = BarChartDataEntry(x: Double(day), y: accumulator)
                    dailyStepDataEntries.append(dailyStepEntry)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E"
                    xLabels.append (formatter.string (from: filterDay!))
                }
                
                let barDataSet = BarChartDataSet(values: dailyStepDataEntries, label: "")
                
                barDataSet.colors = [UIColor.darkGray]
                
                let barData = BarChartData(dataSets: [barDataSet])
                
                let data: CombinedChartData = CombinedChartData()
                data.barData = barData
                
                self.chartView2.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(value, _) in
                    let index = Int(value) + healthKitManager.historyDays
                    if (value == 0) {
                        return "Today"
                    } else {
                        return (xLabels[index])
                    }
                })
                
                self.chartView2.xAxis.axisMinimum = -(Double(healthKitManager.historyDays) + 0.5)
                self.chartView2.xAxis.axisMaximum = 0.5
                
                self.chartView2.data = data
                self.chartView2.data?.notifyDataChanged()
                self.chartView2.notifyDataSetChanged()
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
