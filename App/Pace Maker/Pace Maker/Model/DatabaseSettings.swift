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

//Social에서 follow할 friends searching 기능 구현 위한 함수
//보여주는 것도 비동기 코드 안에서 해야할 것처럼 보임
//Social UI 짠 이후에 이동시킬 예정
func searchUserByContains(_ inputString: String){
    let input = inputString.lowercased()
    let refer = realReference.reference(withPath: "user")
    let users = refer.queryOrdered(byChild: "nick")
    users.observe(.value, with: {snapshot in
        var retUserCandidate: [DataSnapshot] = []
        for child in snapshot.children.allObjects as! [DataSnapshot]{
            let nickName = child.childSnapshot(forPath: "nick").value as! String
            let realName = child.childSnapshot(forPath: "name").value as! String
            
            let nick = nickName.lowercased()
            let name = realName.lowercased()
            
            if (nick.contains(input)) || (name.contains(input)){
                retUserCandidate.append(child)
            }
        }
        print(retUserCandidate)
    })
}
