//
//  User.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import Foundation
import UIKit

var userId: String? = nil
var user: User? = nil

let defaultProfileImage = UIImage(systemName: "person.crop.circle.badge.xmark")

struct User {
    
    // immutable
    let UID :String // PK, 회원 번호
    let email: String
    let name: String
    let age: Int
    
    // mutable
    var nickName: String
    var password: String
    var description: String
    var challenges: [String]
    var friends: [String]
    
    // profile image
    var profileImage: UIImage?
    
    init(UID : String, name: String, email: String, age: Int, nickName: String, challenges: [String], friends: [String], description: String, password: String) {
        self.UID = UID
        self.name = name
        self.email = email
        self.age = age
        self.nickName = nickName
        self.challenges = challenges
        self.friends = friends
        self.password = password
        self.description = description
    }
}
