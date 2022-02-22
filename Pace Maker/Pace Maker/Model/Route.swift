//
//  Log.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/08.
//

import Foundation

struct Log {
    var dateString: String
    var distanceInKilometer: Double
    var routeSavedPath: String
    var runnerUID: String
    var nickname: String
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
    
    var paceDescription: String {
        let min = pace / 60
        let second = pace % 60
        return "\(min) MIN\n\(second) S\n"
    }
    
    var timeDescription: (Int, Int, Int) {
        let timeSpentLearning = Int(timeSpentInSeconds)
        let hour = timeSpentLearning / 3600
        let min = timeSpentLearning / 60
        let second = timeSpentLearning % 60
        return (hour, min, second)
    }
}
