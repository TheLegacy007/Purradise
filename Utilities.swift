//
//  Utilities.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/26/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import Foundation

class Utilities {
    
//    class func loginUser(target: AnyObject) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let welcomeVC = storyboard.instantiateViewControllerWithIdentifier("navigationVC") as! UINavigationController
//        target.presentViewController(welcomeVC, animated: true, completion: nil)
//        
//    }
    
    class func timeElapsed(seconds: NSTimeInterval) -> String {
        var elapsed: String
        if seconds < 60 {
            elapsed = "Just now"
        }
        else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let suffix = (minutes > 1) ? "mins" : "min"
            elapsed = "\(minutes) \(suffix) ago"
        }
        else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let suffix = (hours > 1) ? "hours" : "hour"
            elapsed = "\(hours) \(suffix) ago"
        }
        else {
            let days = Int(seconds / (24 * 60 * 60))
            let suffix = (days > 1) ? "days" : "day"
            elapsed = "\(days) \(suffix) ago"
        }
        return elapsed
    }
}
