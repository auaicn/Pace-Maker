//
//  RegisterViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/16.
//

import UIKit
import UnderKeyboard

class RegisterViewController: UIViewController {
    
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()

    var isCorrectEmailFormat: Bool = false
    var isCorrectPasswordFormat: Bool = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var anotherPassword: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view)
        activityIndicator.hidesWhenStopped = true
//        registerButton.isEnabled = false

        self.email.delegate = self
        self.password.delegate = self
        self.anotherPassword.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editingDidEnd(_ sender: Any) {
//        registerButton.isEnabled = false
        guard isCorrectFormat else { return }
//        registerButton.isEnabled = true
        
    }
    
    @IBAction func registerAction(_ sender: Any) {
        guard verifyCorrectInputFormat() else { return }
        verifyNotDuplicatedEmail()
    }
    
    func verifyCorrectInputFormat() -> Bool {
        guard let emailString = email.text else { return false }
        guard let passwordString = password.text else { return false }
        if !emailString.isValidEmail() {
            alertIncorrectInputFormt(with: "이메일")
            return false
        } else if !passwordString.isValidPassword {
            alertIncorrectInputFormt(with: "비밀번호")
            return false
        }
        return true
    }

    func verifyNotDuplicatedEmail() {
        activityIndicator.startAnimating()
        _ = realReference.reference(withPath: "user")
            .queryOrdered(byChild: "email")
            .queryEqual(toValue: self.email.text)
            .observe(.value) { snapshot in
                self.activityIndicator.stopAnimating()
                
                let found: Bool = snapshot.childrenCount != 0
                if found {
                    self.alertDuplicateEmail()
                }else {
                    self.continueRegisterAction()
                }
            }
    }
    
    func alertIncorrectInputFormt(with message: String){
        let message = "\(message) 형식이 올바르지 않습니다"
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertDuplicateEmail(){
        let message = "이미 이메일 \"(\(email.text!))\"\n 로 등록된 사용자가 있습니다."
        let alertController = UIAlertController(title: "이미 가입된 이메일",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "패스워드 찾기", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func continueRegisterAction(){
        // email NOT duplicated
        // continue registering
        performSegue(withIdentifier: "ContinueRegister", sender: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? RegisterDetailViewController {
            nextViewController.email = email.text
            nextViewController.password = password.text
        }
    }
    
    var isCorrectFormat : Bool {
        get{
            return isCorrectEmailFormat && isCorrectPasswordFormat
        }
    }

}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case self.email:
                self.email.becomeFirstResponder()
            case self.password:
                self.password.becomeFirstResponder()
            case self.password:
                self.anotherPassword.becomeFirstResponder()
            default:
                self.email.resignFirstResponder()
        }
    }
}


extension String {
    
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
