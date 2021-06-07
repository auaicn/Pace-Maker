//
//  RegisterDetailViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/07.
//

import UIKit
import UnderKeyboard
import HealthKit

class RegisterDetailViewController: UIViewController {

    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    var email: String? = nil
    var password: String? = nil
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setInitialValueIfAvailable()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view)
    }
    
    func setInitialValueIfAvailable() {
        let healthStore = HKHealthStore()
        
        if HKHealthStore.isHealthDataAvailable(){
            // nickname
            
            // user name
            name.text = NSFullUserName()
            
//            do {
//                let datesComponents = try healthStore.dateOfBirthComponents()
//            } catch error {
//                print(error)
//            }
//
//            let datesComponents = healthStore.dateOfBirthComponents()
//            // age
//            let calendar = Calendar.current
//
//            let year = calendar.dateComponents([.year], from: datesComponents.date!, to: Date()).year
//            self.age.text = String(year)
        } else {
            return
        }

    }
    
    @IBAction func registerNewUser(_ sender: Any) {
//        let userReference = realReference. child("user")
//        userReference.
        
//        let values: [String: Any] = [
//            "age": 25,
//            "married": true,
//            "name": "kyungho",
//            "team": "pace-maker"
//        ]
//        userItemRef.setValue(values)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
