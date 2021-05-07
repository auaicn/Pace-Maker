//
//  ViewController.swift
//  firebase_test
//
//  Created by 성준오 on 2021/05/06.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class ViewController: UIViewController {

    let storage = Storage.storage()
    let testItemsReference = Database.database(url: "https://fir-test-c5e2f-default-rtdb.asia-southeast1.firebasedatabase.app/").reference(withPath: "test-items")
    
    @IBOutlet weak var imgview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func store(_ sender: Any) {
        // Get a reference to the storage service using the default Firebase App
        
        let a = UIImage(named: "ex")!
        
        // FileManager 인스턴스 생성
        let fileManager = FileManager()

        // 해당 디렉토리 경로
        let desktopPath = "/Users/userName/Desktop"

        do {
            // contentsOfDirectory(atPath:)가 해당 디렉토리 안의 파일 리스트를 배열로 반환
            let contents = try fileManager.contentsOfDirectory(atPath: desktopPath)

            // subpathsOfDirectory(atPath:)가 해당 디렉토리의 하위에 있는 모든 파일을 배열로 반환
            let deeperContents = try fileManager.subpathsOfDirectory(atPath: desktopPath)

            print(contents)
            print(deeperContents)
        } catch let error as NSError {
            print("Error access directory: \(error)")
        }
        
        uploadimage(img:a)
        downloadimage(imgview: imgview)
        
    }
    
    
    @IBAction func realtime(_ sender: Any) {
        uploadingRealtime()
        downloadingRealtime()
    }
    
    func downloadimage(imgview:UIImageView){
        storage.reference(forURL: "gs://fir-test-c5e2f.appspot.com/password").downloadURL { (url, error) in
                           let data = NSData(contentsOf: url!)
                           let image = UIImage(data: data! as Data)
                            imgview.image = image
            }
    }
    
    func uploadimage(img :UIImage){
        var data = Data()
        data = img.jpegData(compressionQuality: 0.8)!
        let filePath = "password1"
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storage.reference().child(filePath).putData(data,metadata: metaData){
                (metaData,error) in if let error = error{
                    print(error.localizedDescription)
                    return
                }else{
                    print("성공")
                }
        }
    }
    
    func uploadXML(){
        var data = Data()
        data = a
        let filePath = "xml_test"
        let metaData = StorageMetadata()
        metaData.contentType = "xml"
        storage.reference().child(filePath).putData(data,metadata: metaData){
                (metaData,error) in if let error = error{
                    print(error.localizedDescription)
                    return
                }else{
                    print("성공")
                }
        }
    }
    
    func downloadingRealtime(){
        testItemsReference.observe(.value, with: {
                    snapshot in
                    print(snapshot)
        })


        testItemsReference.child("user2").observe(.value) {
                    snapshot in
                    let value = snapshot.value as! [String: AnyObject]
                    let name = value["name"] as! String

                    print("name is \(name)")
        }
    }
    
    func uploadingRealtime(){
        let userItemRef = testItemsReference.child("user3")
        let values: [String: Any] = [
            "age": 25,
            "married": true,
            "name": "kyungho",
            "team": "pace-maker"
        ]
        userItemRef.setValue(values)
    }
}




