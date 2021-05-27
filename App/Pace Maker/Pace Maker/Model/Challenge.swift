//
//  Challenge.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import Foundation

struct Challenge{
    
    // 기간
    let start : Date
    let end : Date
    
    // 생성자, 생성된 이름, 생성 목표거리
    let title: String
    let hostId : Int
    let goalDistnace : Int
    
    // 참여자
    let participants: [Int]
}
