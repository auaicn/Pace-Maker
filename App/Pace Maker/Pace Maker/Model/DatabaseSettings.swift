//
//  DatabaseSettings.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/17.
//

import Foundation
import Firebase

let realReference = Database.database(url: "https://pace-maker-74452-default-rtdb.asia-southeast1.firebasedatabase.app/")

let storage = Storage.storage()
let storageUrlBase = "gs://pace-maker-74452.appspot.com/"

//func downloadProfileImage(with iamgeview: UIImageView){
//    let imageUrl = storageUrlBase + "profiles/" + String(DEFAULT_USER_ID)
//    storage.reference(forURL: imageUrl).downloadURL { (url, error) in
//        let data = NSData(contentsOf: url!)
//        let image = UIImage(data: data! as Data)
//        imgview.image = image
//    }
//}

func getProfileImage(imgview: UIImageView){
    let imageUrl = storageUrlBase + "profiles/" + String(DEFAULT_USER_ID)
    storage.reference(forURL: imageUrl).downloadURL { (url, error) in
        let data = NSData(contentsOf: url!)
        let image = UIImage(data: data! as Data)
        imgview.image = image
    }
}

func uploadProfileImage(img: UIImage){
    print("uploadProfileImage")
    var data = Data()
    data = img.pngData()!
    //pngData()와 jpegData() 2개가 있음
    let imageUrl = "profiles/" + String(DEFAULT_USER_ID)
    let metaData = StorageMetadata()
    metaData.contentType = "image/png"
    
    storage.reference().child(imageUrl).putData(data, metadata: metaData){
        (metaData, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        else{
            print("Succecssfully Done")
        }
    }
}

