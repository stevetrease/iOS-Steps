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
        
        print("\(#file) - \(#function)")
        
        chartView3.legend.enabled = false
        chartView3.xAxis.drawLabelsEnabled = true
        chartView3.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView3.xAxis.drawGridLinesEnabled = false
        chartView3.leftAxis.axisMinimum = 0
        chartView3.leftAxis.drawGridLinesEnabled = false
        chartView3.rightAxis.drawLabelsEnabled = false
        chartView3.leftAxis.drawLabelsEnabled = true
        // chartView3.descriptionText = ""
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
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print("\(#file) - \(#function)")
        
        var xLabels: [String] = []
        var firstHour = 24.0
        var lastHour = 0.0
        var lines: [LineChartDataSet] = []
        
        for day in -healthKitManager.historyDays...0 {
            let filterDay = cal.date(byAdding: .day, value: day, to: cal.startOfDay(for: Date()))
            
            var dailySteps = healthKitManager.stepsArray.filter { cal.startOfDay(for: $0.date) == filterDay }
            
            var dailyLineDataEntries: [BarChartDataEntry] = []
            
            var accumulator = 0.0
            for i in 0..<dailySteps.count {
                let cal = Calendar.current
                let d = dailySteps[i].date
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

            let lineDataSet = LineChartDataSet(values: dailyLineDataEntries, label: "Today")
            
            let colourFraction = 1.0 / Double(healthKitManager.historyDays + 1)
            // let whiteValue = 1.0 - (Double(day - 1) * colourFraction * -1.0)
            let whiteValue = (Double(day - 1) * colourFraction * -1.0)

            print (whiteValue)
            
            lineDataSet.colors = [UIColor(white: CGFloat(whiteValue), alpha: 1.0)]
            lineDataSet.drawCirclesEnabled = false
            lineDataSet.lineWidth = 2
            
            if (day == 0) {
                lineDataSet.lineWidth = 3
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
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print ("\(#file) - \(#function)")
        print ("Screen tapped ", type (of: sender))
        
        drawScreen()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        print("\(#file) - \(#function)")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
