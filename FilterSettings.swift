//
//  FilterSettings.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/20/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import Foundation

class FilterSettings {
    
    var geoRadius = 20000.0   // Default is 30000.0, which means no filter on geoLocation.
    var objectName = "All"
    var requiredAction = "All"
    var gender = "All"
    
    init() {
        
    }
}