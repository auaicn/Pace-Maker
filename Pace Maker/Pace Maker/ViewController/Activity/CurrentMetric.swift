//
//  CurrentMetric.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/04.
//

import Foundation
import UIKit

enum CurrentMetric: String{
    case distance, pace, heartRate, activeEnergyBurned
    
    static let allValues = [distance, pace, heartRate, activeEnergyBurned]
    
    var colorSet: UIColor {
        switch self{
            case .distance:
                return UIColor(named: "AppColor-1")!
            case .pace:
                return UIColor(named: "AppColor-2")!
            case .heartRate:
                return UIColor(named: "AppColor-3")!
            case .activeEnergyBurned:
                return UIColor(named: "AppColor-4")!
        }
    }
    
    var unit: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s / km"
            case .heartRate:
                return "bpm"
            case .activeEnergyBurned:
                return "kcal"
        }
    }
    
    var label: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s / km"
            case .heartRate:
                return "bpm"
            case .activeEnergyBurned:
                return "kcal"
        }
    }
    
    var prefix: String {
        switch self{
            case .distance:
                return "총"
            case .pace:
                return "최고 기록"
            default:
                return "평균"
        }
    }
    
    var limitLineLabel: String {
        switch self{
            case .distance:
                return "평균"
            case .pace:
                return "평균"
            case .heartRate:
                return "평균"
            case .activeEnergyBurned:
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
