//
//  DatabaseSettings.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/17.
//

import Foundation
import Firebase

let realtimeReference = Database.database(url: "https://pace-maker-74452-default-rtdb.asia-southeast1.firebasedatabase.app/")
let storageUrlBase = "gs://pace-maker-74452.appspot.com/"
let suffix: String = ".png"

let storage = Storage.storage()

func downloadProfileImage() {
    guard let userId = userId else { return }
    
    let suffix: String = ".png"
    let imageUrl = storageUrlBase + "profiles/\(userId)\(suffix)"
    storage.reference(forURL: imageUrl).downloadURL { (url, error) in
        if let _ = error {
            user?.profileImage = nil
            print("error while downloading profile")
        }
        if url != nil {
            let data = NSData(contentsOf: url!)
            let image = UIImage(data: data! as Data)
            user?.profileImage = image
            print("successfully downloaded profile \(userId)")
        } else {
            // storage 에 해당 이미지가 없는 경우
            print("failed to download profile of UID :\(userId)")
            user?.profileImage = nil
            return
        }
    }
}

func uploadLogImage(with image: UIImage?, named fileName: String){
    guard let image = image else { return }
    
    var data = Data()
    data = image.pngData()!
    
    let imageUrl = storageUrlBase + "log_images/\(fileName)\(suffix)"
    let metaData = StorageMetadata()
    metaData.contentType = "image/png"
    storage.reference(forURL: imageUrl).putData(data, metadata: metaData){
        (metaData, error) in
        if let error = error {
            print("uploadLogImage failed")
            print(error.localizedDescription)
            return
        }
        else{
            print("uploadLogImage Succecssfully Done")
        }
    }
}

func uploadProfileImage(image: UIImage){
    guard let userId = userId else { return }
    
    var data = Data()
    data = image.pngData()!

    let imageUrl = storageUrlBase + "profiles/\(userId)\(suffix)"
    let metaData = StorageMetadata()
    metaData.contentType = "image/png"
    storage.reference(forURL: imageUrl).putData(data, metadata: metaData){
        (metaData, error) in
        if let error = error {
            print("uploadProfileImage failed")
            print(error.localizedDescription)
            return
        }
        else{
            print("uploadProfileImage Succecssfully Done")
        }
    }
}

func getLogImage(imgview: UIImageView, logName: String){
    let imageUrl = storageUrlBase + "log_images/" + logName + ".png"
    storage.reference(forURL: imageUrl).downloadURL { (url, error) in
        if let error = error{
            print(error.localizedDescription)
        }
        else{
            let data = NSData(contentsOf: url!)
            let image = UIImage(data: data! as Data)
            imgview.image = image
        }
    }
}
