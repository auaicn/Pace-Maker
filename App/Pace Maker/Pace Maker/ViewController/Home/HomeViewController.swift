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
    var userId : Int?
    
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAuthenticationStatus(to: .notLoggined)
        setNavigationBar()
        loginAsDefaultUser()
        updateUI()
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
    
    func loginAsDefaultUser() {
        login(with: String(DEFAULT_USER_ID))
    }
    
    func login(with id:String){
        let userReference = realReference.reference(withPath: "user")
        userReference.child(id).observe(.value) { snapshot in
            let userDictionary = snapshot.value as? [String : AnyObject] ?? [:]
            
            let age: Int = userDictionary["age"] as! Int
//            let challenges: [String] = userDictionary["challenges"] as! [String]
            let friends: [String] = userDictionary["friends"] as! [String]
            let email: String = userDictionary["email"] as! String
            let name: String = userDictionary["name"] as! String
            let nick: String = userDictionary["nick"] as! String
            //let passwd: String = userDictionary["passwd"] as! String
            
            user = User(UID: id, name: name, email: email, age: age, nickName: nick, challenges: [], friends: friends)
            self.updateAuthenticationStatus(to: .loggined)
            
            print("logined with UID \(id)")

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
    }
    
}

// 네비게이션 바 관련
extension HomeViewController {
    
    func setNavigationBar() {
        self.navigationItem.leftBarButtonItem = makeNavigationBarItemWithImage()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(tappedLogOut))

//        self.navigationItem.rightBarButtonItem?.action = #selector(tappedLogOut)
        
        // maybe Large Title Stuff
        
        // or hide on swipe things
        
    }
    
    /// Make View For Left Navigation Bar Item using User's profile image
    private func makeNavigationBarItemWithImage() -> UIBarButtonItem{
        let profileImageView = makeRoundImageView()
        
        let customView = UIButton()
        customView.addSubview(profileImageView)
        customView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        customView.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: customView)
        item.target = self
//        item.action = #selector(tappedProfile)
        
        return item;
    }
    
    func makeRoundImageView() -> UIImageView{
        let profileImage = (UIImage(named: "workout")?.withRenderingMode(.alwaysOriginal))!
        let profileImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 32,height: 32)) // hardcoded
        profileImageView.image = profileImage
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
