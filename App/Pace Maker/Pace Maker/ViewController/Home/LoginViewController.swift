//
//  LoginViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import UIKit

import AuthenticationServices
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginAction(_ sender: Any) {
        guard let inputEmail = email.text else {return}
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let myTopPostsQuery = (ref.child("user").child(inputEmail)).queryOrdered(byChild: "email")
        myTopPostsQuery.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
                return;
            }
            else if snapshot.exists() {
                print("Got data \(snapshot.value!)")
                user = User(customerId: 3, name: "", email: inputEmail, age: 22, nickName: "", challenges: [], friends: [])
            }
            else {
                print("No data available")
            }
        }
        performSegue(withIdentifier: "unwindToHomeVC", sender: nil)
    }
    @IBAction func registerAction(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue)
    }
}
