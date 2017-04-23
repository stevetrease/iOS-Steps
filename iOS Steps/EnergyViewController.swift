//
//  EnergyViewController.swift
//  iOS Steps
//
//  Created by Steve on 23/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import Foundation
import HealthKit
import Charts



class EnergyViewController: UIViewController {
    
    @IBOutlet weak var chartView4: CombinedChartView!
    
    private let cal = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(#file) - \(#function)")
        
        chartView4.legend.enabled = false
        chartView4.xAxis.drawLabelsEnabled = true
        chartView4.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView4.xAxis.drawGridLinesEnabled = false
        chartView4.leftAxis.axisMinimum = 0
        chartView4.leftAxis.drawGridLinesEnabled = false
        chartView4.rightAxis.drawLabelsEnabled = false
        chartView4.leftAxis.drawLabelsEnabled = true
        chartView4.chartDescription?.text = ""
        
        chartView4.drawBordersEnabled = false
        chartView4.leftAxis.drawAxisLineEnabled = false
        chartView4.rightAxis.drawAxisLineEnabled = false
        chartView4.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOptionX: .easeInExpo, easingOptionY: .easeInExpo)
        
        chartView4.xAxis.granularity = 1.0
        chartView4.xAxis.granularityEnabled = true
        
        drawScreen()
    }
    
    
    func viewWillAppear() {
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print("\(#file) - \(#function)")
        
        var dailyStepDataEntries: [BarChartDataEntry] = []
        var xLabels: [String] = []
        
        for day in -healthKitManager.historyDays...0 {
            let filterDay = cal.date(byAdding: .day, value: day, to: cal.startOfDay(for: Date()))
            
            let stepsForDay: [(date: Date, value: Double)] = healthKitManager.stepsArray.filter { cal.startOfDay(for: $0.date) == filterDay }
            
            var accumulator = 0.0
            for hour in stepsForDay {
                let value = hour.value
                accumulator = accumulator + value
            }
            // print (day, stepsForDay.count, accumulator)
            
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
        
        self.chartView4.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(value, _) in
            let index = Int(value) + healthKitManager.historyDays
            if (value == 0) {
                return "Today"
            } else {
                return (xLabels[index])
            }
        })
        
        self.chartView4.xAxis.axisMinimum = -(Double(healthKitManager.historyDays) + 0.5)
        self.chartView4.xAxis.axisMaximum = 0.5
        
        self.chartView4.data = data
        self.chartView4.data?.notifyDataChanged()
        self.chartView4.notifyDataSetChanged()
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print ("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        print("\(#file) - \(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
