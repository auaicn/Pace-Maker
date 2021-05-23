//
//  RegisterViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import UIKit

class RegisterViewController: UIViewController {
    
    var isCorrectNameFormat: Bool = false
    var isCorrectEmailFormat: Bool = false
    var isCorrectMobileFormat: Bool = false
    var isCorrectPasswordFormat: Bool = false
    
    var isCorrectFormat : Bool {
        get{
            return isCorrectNameFormat && isCorrectEmailFormat && isCorrectMobileFormat && isCorrectPasswordFormat
        }
    }

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false

        self.name.delegate = self
        self.mobile.delegate = self
        self.password.delegate = self
        self.email.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editingDidEnd(_ sender: Any) {
        registerButton.isEnabled = false
        guard isCorrectFormat else { return }
        registerButton.isEnabled = true
        
    }
    
    @IBAction func registerAction(_ sender: Any) {
        if isDuplicateEmail() {
            let alert = UIAlertController(title: "duplicate email",
                                          message: "you already have signed in with given email",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
            let findPasswordAction = UIAlertAction(title: "find password", style: .default, handler : nil)
            alert.addAction(cancelAction)
            alert.addAction(findPasswordAction)
        }
    }
    
    func isDuplicateEmail() -> Bool{
        return false
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("registered")
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension String {
    func isValidName() -> Bool {
        guard !self.lowercased().hasPrefix("mailto:") else { return false }
        guard let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = emailDetector.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: self.count))
        guard matches.count == 1 else { return false }
        return matches[0].url?.scheme == "mailto"
    }
    
    func isValidEmail() -> Bool {
        guard !self.lowercased().hasPrefix("mailto:") else { return false }
        guard let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = emailDetector.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: self.count))
        guard matches.count == 1 else { return false }
        return matches[0].url?.scheme == "mailto"
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    //validate Password
    var isValidPassword: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$", options: .caseInsensitive)
            if(regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil){
                
                if(self.count>=6 && self.count<=20){
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        } catch {
            return false
        }
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case self.name:
                self.email.becomeFirstResponder()
            case self.email:
                self.mobile.becomeFirstResponder()
            case self.mobile:
                self.email.becomeFirstResponder()
            default:
                self.email.resignFirstResponder()
        }
    }
}
