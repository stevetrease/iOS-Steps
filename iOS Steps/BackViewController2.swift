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
    @IBOutlet weak var chartView3: CombinedChartView!

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
        self.drawChart2()
        
        
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
        self.drawChart3()
        
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
                self.drawChart2()
                self.drawChart3()
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
    
    
    func drawChart2 () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        var dailyStepDataEntries: [BarChartDataEntry] = []
        var xLabels: [String] = []
        
        var averageDailySteps = 0.0
        
        for day in -healthKitManager.historyDays...0 {
            let filterDay = self.cal.date(byAdding: .day, value: day, to: self.cal.startOfDay(for: Date()))
            
            let stepsForDay: [(timeStamp: Date, value: Double)] = healthKitManager.stepsArray.filter { self.cal.startOfDay(for: $0.timeStamp) == filterDay }
            
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
            
            if day != 0 {
                averageDailySteps = averageDailySteps + accumulator
            }
        }
        
        averageDailySteps = averageDailySteps / Double(healthKitManager.historyDays)
        print ("average daily step", averageDailySteps)
        
        let averageLineStartDataEntry = BarChartDataEntry(x: -(Double(healthKitManager.historyDays) + 0.5), y: averageDailySteps)
        let averageLineEndDataEntry = BarChartDataEntry(x: 0.5, y: averageDailySteps)
        var averageLineDataEntries: [BarChartDataEntry] = []
        averageLineDataEntries.append (averageLineStartDataEntry)
        averageLineDataEntries.append (averageLineEndDataEntry)
        let averageLineDataSet = LineChartDataSet (values: averageLineDataEntries, label: "average")
        averageLineDataSet.colors = [.gray]
        averageLineDataSet.drawCirclesEnabled = false
        averageLineDataSet.lineWidth = 2
        var lines: [LineChartDataSet] = []
        lines.append(averageLineDataSet)

        let barDataSet = BarChartDataSet(values: dailyStepDataEntries, label: "")
        
        barDataSet.colors = [UIColor.lightGray]
        
        let barData = BarChartData(dataSets: [barDataSet])
        let lineData = LineChartData (dataSets: lines)
        
        let data: CombinedChartData = CombinedChartData()
        data.barData = barData
        // data.lineData = lineData
 
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
    
    
    func drawChart3 () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        var firstHour = 24.0
        var lastHour = 0.0
        var lines: [LineChartDataSet] = []
        
        var averageDailySteps = 0.0
        var maxSteps = 0.0
        
        for day in -healthKitManager.historyDays...0 {
            let filterDay = self.cal.date(byAdding: .day, value: day, to: self.cal.startOfDay(for: Date()))
            
            var dailySteps = healthKitManager.stepsArray.filter { self.cal.startOfDay(for: $0.timeStamp) == filterDay }
            
            var dailyLineDataEntries: [BarChartDataEntry] = []
            
            var accumulator = 0.0
            for i in 0..<dailySteps.count {
                let d = dailySteps[i].timeStamp
                let components = cal.dateComponents ([.hour, .minute], from: d)
                let hour = Double(components.hour!)
                let minutes = Double(components.minute!)
                
                accumulator = accumulator + dailySteps[i].value
                let value = accumulator
                
                if ((hour + (minutes / 60)) < firstHour) {
                    firstHour = (hour + (minutes / 60))
                }
                if ((hour + (minutes / 60)) > lastHour) {
                    lastHour = (hour + (minutes / 60))
                }
                
                if day != 0 {
                    averageDailySteps = averageDailySteps + dailySteps[i].value
                }
                
                if value > maxSteps {
                    maxSteps = value
                }
                
                let dailyLineDataEntry = BarChartDataEntry(x: hour + (minutes / 60), y: value)
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
        
        averageDailySteps = averageDailySteps / Double(healthKitManager.historyDays)
        print ("average daily step", averageDailySteps)
        
        let averageLineStartDataEntry = BarChartDataEntry(x: firstHour, y: averageDailySteps)
        let averageLineEndDataEntry = BarChartDataEntry(x: lastHour, y: averageDailySteps)
        var averageLineDataEntries: [BarChartDataEntry] = []
        averageLineDataEntries.append (averageLineStartDataEntry)
        averageLineDataEntries.append (averageLineEndDataEntry)
        let averageLineDataSet = LineChartDataSet (values: averageLineDataEntries, label: "average")
        averageLineDataSet.colors = [.lightGray]
        averageLineDataSet.drawCirclesEnabled = false
        averageLineDataSet.lineWidth = 1
        lines.append(averageLineDataSet)
        
        /*
        let components = cal.dateComponents ([.hour, .minute], from: Date())
        let hour = Double(components.hour!)
        let minutes = Double(components.minute!)
        let now = hour + (minutes / 60)
        
        let nowLineStartDataEntry = BarChartDataEntry(x: now, y: 0)
        let nowLineEndDataEntry = BarChartDataEntry(x: now, y: maxSteps)
        var nowLineDataEntries: [BarChartDataEntry] = []
        nowLineDataEntries.append (nowLineStartDataEntry)
        nowLineDataEntries.append (nowLineEndDataEntry)
        let nowLineDataSet = LineChartDataSet (values: nowLineDataEntries, label: "")
        nowLineDataSet.colors = [.lightGray]
        nowLineDataSet.drawCirclesEnabled = false
        nowLineDataSet.lineWidth = 0.5
        lines.append(nowLineDataSet)
        */
 
        let data: CombinedChartData = CombinedChartData()
        let lineData = LineChartData (dataSets: lines)
        
        data.lineData = lineData
        
        self.chartView3.data = data
        self.chartView3.data?.notifyDataChanged()
        self.chartView3.notifyDataSetChanged()
    }
}
