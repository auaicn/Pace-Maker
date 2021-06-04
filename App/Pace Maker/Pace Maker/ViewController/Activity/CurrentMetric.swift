//
//  CurrentMetric.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/04.
//

import Foundation

enum CurrentMetric: String{
    case distance, pace, heartRate, activeEnergyBurned
    
    static let allValues = [distance, pace, heartRate, activeEnergyBurned]
    
    var unit: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s per km"
            case .heartRate:
                return "per minute"
            case .activeEnergyBurned:
                return "per minute"
        }
    }
    
    var label: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s per km"
            case .heartRate:
                return "per minute"
            case .activeEnergyBurned:
                return "per minute"
        }
    }
    
    var prefix: String {
        switch self{
            case .distance:
                return "총"
            case .pace:
                return "최대"
            default:
                return "평균"
        }
    }
    
    var summaryFormat: String {
        switch self{
            case .distance:
                return "%.1f"
            case .pace:
                return "%d m %d s"
            case .heartRate:
                return "%.0f"
            case .activeEnergyBurned:
                return "%.0f"
        }
    }
}

var currentMetric: CurrentMetric = .distance
