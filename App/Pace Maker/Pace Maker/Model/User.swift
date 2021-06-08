//
//  User.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import Foundation
import UIKit

let DEFAULT_USER_ID: Int = 1
var user: User? = nil
var profileImage: UIImage? = nil

struct User {
    
    let UID : String // PK, 회원 번호
    let name: String
    let email : String
    let age: Int
    let nickName: String
    let challenges : [String]
    let friends : [String]
    
    init(UID : String, name: String, email: String, age: Int, nickName: String, challenges: [String], friends:[String]) {
        self.UID = UID
        self.name = name
        self.email = email
        self.age = age
        self.nickName = nickName
        self.challenges = challenges
        self.friends = friends
        
        profileImage = UIImage(systemName: "person.crop.circle.badge.xmark")
    }
}

/// LastName 성 = given name = familyname
/// FirstName 이름
struct FullName {
    let givenFamilyName: String
    let firstName: String
}

