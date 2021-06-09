//
//  Route.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/08.
//

import Foundation

struct Route{
    var dateString: String
    var distanceInKilometer: Double
    var routeSavedPath: String
    var runnerUID: String
    var timeSpentInSeconds : Double
    
    var pace: Int {
        let paceInSeconds: Int = Int(timeSpentInSeconds / distanceInKilometer)
        return paceInSeconds
    }
    
    var paceString: String {
        let min = pace / 60
        let second = pace % 60
        return "\(min):\(second)"
    }
}
