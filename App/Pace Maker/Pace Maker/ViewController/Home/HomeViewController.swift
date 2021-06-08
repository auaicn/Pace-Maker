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

    var userIdentifierString: String?
    
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var screenImageView: UIImageView!
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAuthenticationStatus(to: .notLoggined)
        setNavigationBar()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        login()
    }
    
    func updateUI(){
        updateProfile()
        
    }
    
    func updateProfile(){
        if authenticationStatus == .loggined{
            
        }
    }

}

// 로그인 관련
extension HomeViewController {
    
    func login(){
        guard let userId = userId else {
            print("failed to login")
            return
        }
        let userReference = realReference.reference(withPath: "user")
        userReference.child(userId).observeSingleEvent(of: .value) { snapshot in
            let userDictionary = snapshot.value as? [String : AnyObject] ?? [:]
            
            let age: Int = userDictionary["age"] as! Int
            let email: String = userDictionary["email"] as! String
            let name: String = userDictionary["name"] as! String
            let nick: String = userDictionary["nick"] as! String
            
            let friends: [String] = userDictionary["friends"] as? [String] ?? []
            let challenges: [String] = userDictionary["challenges"] as? [String] ?? []
            // let passwd: String = userDictionary["passwd"] as! String 로그인시에는 필요없어 보인다
            
            user = User(UID: userId, name: name, email: email, age: age, nickName: nick, challenges: challenges, friends: friends)
            self.updateAuthenticationStatus(to: .loggined)
            
            print("logined with UID \(userId)")

        }
    }
    
    func updateAuthenticationStatus(to newStatus: AuthenticationStatus) {
        authenticationStatus = newStatus
        switch newStatus {
            case .notLoggined:
                navigationItem.rightBarButtonItem?.isEnabled = false
                navigationItem.rightBarButtonItem?.tintColor = .gray
            case .loggined:
                navigationItem.rightBarButtonItem?.isEnabled = true
                navigationItem.rightBarButtonItem?.tintColor = .label
        }
        updateUI()
    }
    
}

// 네비게이션 바 관련
extension HomeViewController {
    
    func setNavigationBar() {
        self.navigationItem.leftBarButtonItem = makeNavigationBarItemWithImage()
        self.navigationItem.rightBarButtonItem = makeCameraScreenshotImage()

//        self.navigationItem.rightBarButtonItem?.action = #selector(tappedCamera)
        
        // maybe Large Title Stuff
        
        // or hide on swipe things
        
    }
    
    /// Make View For Left Navigation Bar Item using User's profile image
    private func makeCameraScreenshotImage() -> UIBarButtonItem {
        
        let profileImageView = user?.profileImage != nil ? makeRoundImageView(with: (user?.profileImage)!) : UIImageView(image: defaultProfileImage)
        
        let customView = UIButton()
        customView.addSubview(profileImageView)
        customView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        customView.addTarget(self, action: #selector(tappedCamera), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: customView)
        item.target = self
        
        return item;
    }
    
    @objc func tappedCamera(){
        print("tappedCamera")
        screenImageView.image = view.takeScreenshot()
    }
    
    /// Make View For Left Navigation Bar Item using User's profile image
    private func makeNavigationBarItemWithImage() -> UIBarButtonItem {
        
        let profileImageView = user?.profileImage != nil ? makeRoundImageView(with: (user?.profileImage)!) : UIImageView(image: defaultProfileImage)
        
        let customView = UIButton()
        customView.addSubview(profileImageView)
        customView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        customView.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: customView)
        item.target = self
//        item.action = #selector(tappedProfile)
        
        return item;
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
