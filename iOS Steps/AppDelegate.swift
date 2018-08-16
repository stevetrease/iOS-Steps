//
//  AppDelegate.swift
//  iOS Steps
//
//  Created by Steve on 29/01/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

// var watchConnectivityHandler : WatchConnectivityHandler?


@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myViewController:DayViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        print ("device uuid ", (UIDevice.current.identifierForVendor?.uuidString)!)
        
        let appName: String = (Bundle.main.infoDictionary?["CFBundleName"] as? String)!
        let versionNumber: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String)!
        print ("\(appName)  (\(versionNumber))")
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        
        /*
        let stepCountSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)

        let stepCountQuery = HKObserverQuery(sampleType: stepCountSampleType!, predicate: nil) {
            query, completionHandler, error in
            
            // let dateString = formatter.string(from: Date())
            // print ("step count query handler at   \(dateString)")
            
            if error != nil {
                // Perform Proper Error Handling Here...
                print ("*** An error occured while setting up the stepCount observer. \(String(describing: error?.localizedDescription)) ***")
                abort()
            }
            
            self.myViewController?.drawScreenHKObserverQuery()
            
            completionHandler()
        }
      
        healthKitManager.healthStore.execute(stepCountQuery
         */
  
        return true
    }
    
    
    func application (_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function) \(shortcutItem.type)")
        
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return
        }
        
        switch shortcutItem.type {
        case "eu.trease.iosteps.option1":
            tabBarController.selectedIndex = 0
        case "eu.trease.iosteps.week":
            tabBarController.selectedIndex = 1
        default:
            print ("error \(shortcutItem.type)")
        }
    }
    
    
    /*
    func application (application: UIApplicationShortcutItem, shortcutItem: UIApplicationShortcutItem, completionHandeler: (Bool) -> Void) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        print(shortcutItem.type)
    }
    */

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        myViewController?.drawScreen()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        // myViewController?.drawScreen()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
    }
}

