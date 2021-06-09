//
//  User.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import Foundation
import UIKit

let DEFAULT_USER_ID: Int = 1
var userId: String? = nil
var user: User? = nil

let defaultProfileImage = UIImage(systemName: "person.crop.circle.badge.xmark")

struct User {
    
    let UID :String // PK, 회원 번호
    var name: String
    let email: String
    let age: Int
    var nickName: String
    let challenges: [String]
    let friends: [String]
    
    var profileImage: UIImage?
    var discription: String?
    
    init(UID : String, name: String, email: String, age: Int, nickName: String, challenges: [String], friends:[String]) {
        self.UID = UID
        self.name = name
        self.email = email
        self.age = age
        self.nickName = nickName
        self.challenges = challenges
        self.friends = friends
        self.profileImage = nil
    }
    
    init(UID : String, name: String, email: String, age: Int, nickName: String, challenges: [String], friends:[String], profileImage: UIImage?) {
        self.UID = UID
        self.name = name
        self.email = email
        self.age = age
        self.nickName = nickName
        self.challenges = challenges
        self.friends = friends
        self.profileImage = profileImage
    }
}
