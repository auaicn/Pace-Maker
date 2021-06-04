//
//  Format.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/26.
//

import Foundation

let dateFormatter = DateFormatter()

func configureFormatter() {
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
}
