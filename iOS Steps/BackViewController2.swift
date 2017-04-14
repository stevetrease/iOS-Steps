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
        
        print("\(#file) - \(#function)")
        
        chartView2.legend.enabled = false
        chartView2.xAxis.drawLabelsEnabled = true
        chartView2.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView2.xAxis.drawGridLinesEnabled = false
        chartView2.leftAxis.axisMinimum = 0
        chartView2.leftAxis.drawGridLinesEnabled = false
        chartView2.rightAxis.drawLabelsEnabled = false
        chartView2.leftAxis.drawLabelsEnabled = true
        // chartView2.descriptionText = ""
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
        print("\(#file) - \(#function)")
        
        drawScreen()
    }
    
    
    func drawScreen () {
        print("\(#file) - \(#function)")
        
        var dailyStepDataEntries: [BarChartDataEntry] = []
        
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
        }
        
        let barDataSet = BarChartDataSet(values: dailyStepDataEntries, label: "")
        
        barDataSet.colors = [UIColor.darkGray]
        
        let barData = BarChartData(dataSets: [barDataSet])
        
        let data: CombinedChartData = CombinedChartData()
        data.barData = barData
        
        self.chartView2.xAxis.axisMinimum = -(Double(healthKitManager.historyDays) + 0.5)
        self.chartView2.xAxis.axisMaximum = 0.5
        
        self.chartView2.data = data
        self.chartView2.data?.notifyDataChanged()
        self.chartView2.notifyDataSetChanged()
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
