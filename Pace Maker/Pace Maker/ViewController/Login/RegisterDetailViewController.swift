//
//  RegisterDetailViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/07.
//

import UIKit
import UnderKeyboard
import HealthKit
import Firebase

class RegisterDetailViewController: UIViewController {

    let DEFAULT_AGE: Int = 25
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    var email: String? = nil
    var password: String? = nil
    
    var ages: [Int] = Array(Range(10...80))
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setPickerView()
        setInitialValueIfAvailable()
        activityIndicator.hidesWhenStopped = true
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view)
    }
    
    func setPickerView() {
        let pickerView = UIPickerView()
        age.inputView = pickerView
        
        // set default value
        pickerView.delegate = self
        if let indexPosition = ages.firstIndex(of: DEFAULT_AGE){
            pickerView.selectRow(indexPosition, inComponent: 0, animated: true)
        }
    }
    
    func setInitialValueIfAvailable() {
        let _ = HKHealthStore()
        
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
        guard let name = name.text,
              let nickname = nickname.text,
              let age = age.text else { return }
        let userReference = realtimeReference.reference().child("user").childByAutoId()
        guard let newUserId = userReference.key else { return }
        userId = newUserId
        let values: [String: Any] = [
            "email": email!,
            "passwd": password!,
            "name": name,
            "nick": nickname,
            "age": Int(age)!,
            "challenges": [],
            "friends": [],
            "description": []
        ]
        userReference.setValue(values)
        performSegue(withIdentifier: "unwindToHome", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? HomeViewController {
            destVC.loginRequested = true
        }
    }
}

extension RegisterDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(ages[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        age.text = String(ages[row])
    }
}
