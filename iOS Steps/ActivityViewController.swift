
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit


class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // one section per unique day in the workoutData
    func numberOfSections(in tableView: UITableView) -> Int {
        let days = healthKitManager.workoutData.map { cal.startOfDay(for :$0.startDate) }
        
        var uniqueDays: [Date] = []
        for item in days {
            if !uniqueDays.contains(item) {
                uniqueDays.append(item)
            }
        }
        
        return uniqueDays.count
    }
    
    
    // custom section header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var leftLabelText = "Today"
        if section != 0 {
            let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            leftLabelText = formatter.string (from: day!)
        }
        
        let header = tableView.dequeueReusableCell(withIdentifier: "cellIDHeader") as! CustomTableViewHeaderCell
        
        header.leftLabel.text = leftLabelText
        header.rightLabel.text = ""
        
        // header.layer.cornerRadius = 5
        
        return header
    }
    
    
    // standard title for the section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        
        if section == 0 {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter.string (from: day!)
        }
    }
    
    
    // one row in each section for each workout in that day in the workoutData
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        return dayData.count
    }
    
    
    // nicely formatted custom TableViewCell for each workoutData item
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = cal.date(byAdding: .day, value: -indexPath.section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        let workout = dayData[indexPath.row]
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .positional
        timeFormatter.allowedUnits = [ .hour, .minute ]
        timeFormatter.zeroFormattingBehavior = [ .dropLeading ]
        
        let components1 = cal.dateComponents( [.hour, .minute], from: workout.startDate)
        var timeString = timeFormatter.string(from: components1)!
        
        let components2 = cal.dateComponents( [.hour, .minute], from: workout.endDate)
        timeString = timeString + " - " + timeFormatter.string(from: components2)!
        
        let timeFormatter2 = DateComponentsFormatter()
        timeFormatter2.unitsStyle = .abbreviated
        timeFormatter2.allowedUnits = [ .hour, .minute ]
        timeFormatter2.zeroFormattingBehavior = [ .dropLeading ]
        let durationString = timeFormatter2.string(from: workout.duration)!
        
        let energyFormatter = EnergyFormatter()
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        energyFormatter.unitStyle = .medium
        let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
        let energyString = energyFormatter.string(fromValue: energy!, unit: .calorie)
        
        let distance = Measurement(value: (workout.totalDistance?.doubleValue(for: HKUnit.mile()))!, unit: UnitLength.miles)
        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitStyle = .medium
        distanceFormatter.numberFormatter.maximumFractionDigits = 1
        distanceFormatter.numberFormatter.minimumFractionDigits = 1
        let distanceString = distanceFormatter.string(from: distance)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIDwalking")! as! CustomTableViewCell
        cell.energyLabel.text = energyString
        cell.durationLabel.text = durationString
        cell.timeLabel.text = timeString
        cell.distanceLabel.text = distanceString
        cell.activityLabel.text = healthKitManager.workoutTypeIcon(workout.workoutActivityType)
        // cell.activityImage.image = healthKitManager.workoutTypeImage(workout.workoutActivityType)
        
        return cell
    }
    
    
    // refresh workoutData and then update the tableView
    func getData () {
        healthKitManager.getWorkouts (completion: { (x) in
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
    }
    
    
    // screen tap to refresh workoutData
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
}
