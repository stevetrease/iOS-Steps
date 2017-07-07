//
//  WatchKitSessionMananager.swift
//  iOS Steps
//
//  Created by Steve on 09/04/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityHandler: NSObject, WCSessionDelegate {
    
    var session = WCSession.default
    
    override init() {
        super.init()
        
        session.delegate = self
        session.activate()
        
        print ("Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print ("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print ("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print ("sessionDidDeactivate: \(session)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print ("sessionWatchStateDidChange: \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print ("didReceiveMessage: %@", message)
        if message["request"] as? String == "date" {
            replyHandler(["date" : "\(Date())"])
        }
    }
    
    func sendMessage (message: String) {
        print ("sending message \"\(message)\"")
    }
}
