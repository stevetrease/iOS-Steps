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


class DayViewController: UIViewController {
    
    @IBOutlet weak var todayStepCountLabel: UILabel!
    @IBOutlet weak var yesterdayStepCountLabel: UILabel!
    @IBOutlet weak var averageStepCountLabel: UILabel!
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: NSNotification.Name(rawValue: healthKitDidUpdateNotification1), object: nil)
        
        
        todayStepCountLabel.text = ""
        yesterdayStepCountLabel.text = ""
        averageStepCountLabel.text = ""
        
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
        
        updateHealthData()
        drawScreen()
    }
    
    
    func drawScreenHKObserverQuery () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        drawScreen()
    }
    
    
    func updateHealthData () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
    }
    
    
    @objc func notificationReceived () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        self.drawChart()
    }
    
    
    func drawScreen () {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        
        healthKitManager.getTodayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsToday as NSNumber)!
                self.todayStepCountLabel.text = "\(number) today"
            }
            generator.impactOccurred()
        })
        
        healthKitManager.getYesterdayStepCount (completion: { (steps) in
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsYesterday as NSNumber)!
                self.yesterdayStepCountLabel.text = "\(number) yesterday"
            }
        })
        
        healthKitManager.getStepsAverage (completion: { (steps) in
            OperationQueue.main.addOperation {
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let number = numberFormatter.string(from: healthKitManager.stepsAverage as NSNumber)!
                
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.numberStyle = NumberFormatter.Style.spellOut
                let number2 = numberFormatter.string(from: healthKitManager.historyDays as NSNumber)!
                
                self.averageStepCountLabel.text = "\(number) \(number2) day average"
            }
        })
        
        OperationQueue.main.addOperation {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        healthKitManager.updateHourlyStepsArray(completion: { (steps) in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.drawChart()
            }
        })
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        drawScreen()
    }
    
    
    override func didReceiveMemoryWarning() {
        print("\(#file) - \(#function)")
        // Dispose of any resources that can be recreated.
    }
    
    
    func drawChart () {
        var hourlyDataEntries: [BarChartDataEntry] = []
        var line1Data: [ChartDataEntry] = []
        var line2Data: [ChartDataEntry] = []
        
        var firstHour = 24.0
        var lastHour = 0.0
        
        // today line data
        let dailyStepsToday = healthKitManager.hourlySteps
        var accumulator = 0.0
        for i in 0..<dailyStepsToday.count {
            let cal = Calendar.current
            let d = dailyStepsToday[i].timeStamp
            let components = cal.dateComponents ([.hour, .minute], from: d)
            let hour = Double(components.hour!)
            let minutes = Double(components.minute!)
            
            accumulator = accumulator + dailyStepsToday[i].value
            let value = accumulator
            
            if (hour < firstHour) {
                firstHour = hour
            }
            if (hour > lastHour) {
                lastHour = hour
            }
            
            let dailyLineDataEntry = BarChartDataEntry(x: hour + (minutes / 60), y: value)
            line1Data.append(dailyLineDataEntry)
        }
        
        // hourly bar data
        let cal = Calendar.current
        for hour in Int(firstHour)...Int(lastHour) {
            let hourlySteps = dailyStepsToday.filter { cal.component(.hour, from: $0.timeStamp) == hour }
            
            var sum = 0.0
            hourlySteps.forEach { item in
                sum = sum + item.value
            }
            
            let hourlyDataEntry = BarChartDataEntry(x: Double(hour), y: sum)
            hourlyDataEntries.append(hourlyDataEntry)
        }
        
        // yesterday line data
        let dailyStepsYesterday = healthKitManager.hourlyStepsYesterday
        accumulator = 0.0
        for i in 0..<dailyStepsYesterday.count {
            let cal = Calendar.current
            let d = dailyStepsYesterday[i].timeStamp
            let components = cal.dateComponents ([.hour, .minute], from: d)
            let hour = Double(components.hour!)
            let minutes = Double(components.minute!)
            
            accumulator = accumulator + dailyStepsYesterday[i].value
            let value = accumulator
            
            if (hour < firstHour) {
                firstHour = hour
            }
            if (hour > lastHour) {
                lastHour = hour
            }
            
            let dailyLineDataEntry = BarChartDataEntry(x: hour + (minutes / 60), y: value)
            line2Data.append(dailyLineDataEntry)
        }
        
        let averageLineStartDataEntry = BarChartDataEntry(x: firstHour - 0.5, y: healthKitManager.stepsAverage)
        let averageLineEndDataEntry = BarChartDataEntry(x: lastHour + 0.5, y: healthKitManager.stepsAverage)
        var averageLineDataEntries: [BarChartDataEntry] = []
        averageLineDataEntries.append (averageLineStartDataEntry)
        averageLineDataEntries.append (averageLineEndDataEntry)
        let averageLineDataSet = LineChartDataSet (values: averageLineDataEntries, label: "Average")
        averageLineDataSet.colors = [.lightGray]
        averageLineDataSet.drawValuesEnabled = false
        averageLineDataSet.drawCirclesEnabled = false
        averageLineDataSet.lineWidth = 1
        
        let barDataSet = BarChartDataSet(values: hourlyDataEntries, label: "")
        let lineDataSet1 = LineChartDataSet(values: line1Data, label: "Today")
        let lineDataSet2 = LineChartDataSet(values: line2Data, label: "Yesterday")
        
        barDataSet.colors = [UIColor.darkGray]
        lineDataSet1.colors = [UIColor.darkText]
        lineDataSet1.drawCirclesEnabled = false
        lineDataSet1.lineWidth = 3
        lineDataSet2.colors = [UIColor.lightGray]
        lineDataSet2.drawCirclesEnabled = false
        lineDataSet2.lineWidth = 2
        
        let barData = BarChartData(dataSets: [barDataSet])
        let lineData = LineChartData (dataSets: [averageLineDataSet, lineDataSet2, lineDataSet1])
        
        lineData.setDrawValues(false)
        
        let data: CombinedChartData = CombinedChartData()
        data.barData = barData
        data.lineData = lineData
        
        self.chartView.xAxis.axisMinimum = firstHour - 0.5
        self.chartView.xAxis.axisMaximum = lastHour + 0.5
        
        self.chartView.data = data
        self.chartView.data?.notifyDataChanged()
        self.chartView.notifyDataSetChanged()
    }
    
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        shareButton.isHidden = true
        let imageToShare: UIImage = self.view.snapShot()
        shareButton.isHidden = false
        
        let objectsToShare = [imageToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender
        self.present(activityVC, animated: true, completion: nil)
    }
}
