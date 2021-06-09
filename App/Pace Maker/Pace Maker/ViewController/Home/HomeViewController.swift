//
//  CustomHomeViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/14.
//

import UIKit
import Firebase

enum AuthenticationStatus {
    case notLoggined,loggined
}

var authenticationStatus : AuthenticationStatus = .loggined
var homeScreenChallengeIndex : Int = 0

class HomeViewController: UIViewController{
    
    var loginRequested: Bool = true

    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAuthenticationStatus(to: .notLoggined)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tryLogin()
    }
    
    func updateUI(){
        updateProfileImage()
    }
}

// 로그인 관련
extension HomeViewController {
    
    func tryLogin(){
        guard let userId = userId else {
            print("user Id not set")
            return
        }
        if !loginRequested {
            print("already logined")
            return;
        }else {
            loginRequested = false // used up request
            let userReference = realtimeReference.reference(withPath: "user")
            userReference.child(userId).observeSingleEvent(of: .value) { snapshot in
                let userDictionary = snapshot.value as? [String : AnyObject] ?? [:]
                
                let UID: String = snapshot.key
                
                let age: Int = userDictionary["age"] as! Int
                let email: String = userDictionary["email"] as! String
                let name: String = userDictionary["name"] as! String
                let nick: String = userDictionary["nick"] as! String
                let password: String = userDictionary["passwd"] as! String // 로그인 단계에서는 필요없어 보인다.
                
                let challenges: [String] = userDictionary["challenges"] as? [String] ?? []
                let friends: [String] = userDictionary["friends"] as? [String] ?? []
                let description: String = userDictionary["friends"] as? String ?? "설정에서 설명을 추가해주세요"
                
                user = User(UID: UID, name: name, email: email, age: age, nickName: nick, challenges: challenges, friends: friends, description: description, password: password)
                self.updateAuthenticationStatus(to: .loggined)
                print("successfully logined with UID \(userId)")
                
                self.download()

            }
        }
    }
    
    func download() {
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
                self.updateUI()
            } else {
                // storage 에 해당 이미지가 없는 경우
                print("failed to download profile of UID :\(userId)")
                user?.profileImage = nil
                return
            }
        }
    }
    
    func updateAuthenticationStatus(to newStatus: AuthenticationStatus) {
        authenticationStatus = newStatus
        switch newStatus {
            case .notLoggined:
                print("authenticationStatus chagned to \"notLoggined\" status now")
            case .loggined:
                print("authenticationStatus chagned to \"loggined\" status now")
        }
        updateUI()
    }
    
}

// 네비게이션 바 관련
extension HomeViewController {
    
    private func updateProfileImage(){
        
        var imageViewToUpdate: UIImageView? = nil
        
        if let user = user,
           let profileImage = user.profileImage {
            imageViewToUpdate = makeRoundImageView(with: profileImage)
        } else {
            guard let defaultImage = defaultProfileImage else {
                print("default image not set")
                return
            }
            imageViewToUpdate = UIImageView(image: defaultImage)
        }
        
        guard let imageViewToUpdate_ = imageViewToUpdate else {
            print("imageViewToUpdate not set")
            return
        }
        
        let customView = UIButton()
        customView.addSubview(imageViewToUpdate_)
        customView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        customView.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        
        leftBarButtonItem.customView = customView
//        let item = UIBarButtonItem(customView: customView)
//        item.target = self
        
//        leftBarButtonItem = item
        print("successfully profile image updated")
    }
    
    func makeRoundImageView(with image: UIImage) -> UIImageView {
        let renderedProfileImage = image.withRenderingMode(.alwaysOriginal)
        let profileImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 32,height: 32)) // hardcoded
        profileImageView.image = renderedProfileImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        return profileImageView
    }
    
    @objc func tappedProfile(){
        print("tapped profile image")
        switch authenticationStatus {
            case .loggined:
                // 로그인이 되어있는 경우, 세팅 화면으로 이동한다
                performSegue(withIdentifier: "Setting", sender: nil)
            case .notLoggined:
                // 로그인이 안 되어있는 경우, 로그인 화면으로 이동한다
                performSegue(withIdentifier: "Login", sender: nil)
        }
    }
    
    @objc func tappedLogOut() {
        switch authenticationStatus {
            case .loggined:
                updateAuthenticationStatus(to: .notLoggined)
            case .notLoggined:
                return
        }
    }
}

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
