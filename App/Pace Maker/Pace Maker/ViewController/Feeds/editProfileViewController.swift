//
//  editProfileViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/23.
//

import UIKit
import UnderKeyboard


class editProfileViewController: UIViewController, UITextViewDelegate {
    
    let imagePicker = UIImagePickerController()
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    @IBOutlet weak var profileStack: UIStackView!
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editName: UILabel!
    @IBOutlet weak var editEmail: UILabel!
    @IBOutlet weak var editNickName: UITextField!
    @IBOutlet weak var editDescription: UITextView!
    @IBOutlet weak var editPassword: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage(tapGestureRecognizer:)))
        editProfileImage.addGestureRecognizer(tapGestureRecognizer)
        editProfileImage.isUserInteractionEnabled = true
        
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = true // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
        // Do any additional setup after loading the view.
        
        editProfileImage.contentMode = .scaleAspectFill
        editProfileImage.layer.cornerRadius = editProfileImage.frame.width / 2
        editProfileImage.clipsToBounds = true
        
        editDescription.delegate = self
        editDescription.layer.borderWidth = 0.5
        editDescription.layer.borderColor = UIColor.systemGray4.cgColor
        editDescription.layer.cornerRadius = 5
        
        placeholderSetting()
        loadProfile()
        underKeyboardLayoutConstraint.setup(bottomLayoutConstraint, view: view)

    }
    
    func loadProfile() {
        editProfileImage.image = user?.profileImage != nil ? user?.profileImage! : defaultProfileImage!
        editName.text = user?.name
        editNickName.text = user?.nickName
        editEmail.text = user?.email
        editPassword.text = user?.password
        editDescription.text = user?.description
    }
    
    func placeholderSetting() {
        editDescription.delegate = self // txtvReview가 유저가 선언한 outlet
        if user?.description == nil {
            editDescription.text = "Description"
            editDescription.textColor = UIColor.systemGray3
        } else {
            editDescription.text = user?.description
        }
    }
        
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray3 {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
       
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.systemGray3
        }
    }

    
    func verifyCorrectInputFormat() -> Bool {
        guard let nameString = editName.text else { return false }
        guard let nickNameString = editNickName.text else { return false }
        guard let passwordString = editPassword.text else { return false }
        if nameString == "" {
            alertIncorrectInputFormt(with: "이름")
            return false
        } else if nickNameString == "" {
            alertIncorrectInputFormt(with: "닉네임")
            return false
        } else if !passwordString.isValidPassword {
            alertIncorrectInputFormt(with: "비밀번호")
            return false
        }
        return true
    }
    
    func alertIncorrectInputFormt(with message: String){
        let message = "\(message) 형식이 올바르지 않습니다"
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func pickImage(tapGestureRecognizer: UITapGestureRecognizer){
        self.present(self.imagePicker, animated: true)
    }
    
    @IBAction func pressSaveButton(_ sender: UIButton) {
        guard verifyCorrectInputFormat() else { return }
        
        updateUser()
        navigationController?.popViewController(animated: true)
//        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func updateUser() {
        user?.nickName = editNickName.text!
        user?.password = editPassword.text!
        user?.description = editDescription.text
        guard let user = user else { return }
        // 바꿀 값
        let values: [String: Any] = [
            "email": user.email,
            "passwd": String(editPassword.text!),
            "name": String(editName.text!),
            "nick": String(editNickName.text!),
            "age": user.age,
            "challenges": user.challenges,
            "friends": user.friends
        ]
            
        // 바꾸는쿼리
        let _ = realtimeReference.reference().child("user")
            .child(user.UID)
            .setValue(values)
    }
}

extension editProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = editProfileImage.image // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        
        if let newProfileImage = newImage {
            editProfileImage.image = newProfileImage // 받아온 이미지를 update
            user?.profileImage = newProfileImage
            uploadProfileImage(image: newProfileImage)
        }
        
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        
        
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
