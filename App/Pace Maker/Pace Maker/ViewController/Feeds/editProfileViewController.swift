//
//  editProfileViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/23.
//

import UIKit


class editProfileViewController: UIViewController, UITextViewDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editNickName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editProfileStory: UITextView!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var profileStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        editProfileStory.delegate = self
        editProfileStory.layer.borderWidth = 0.5
        editProfileStory.layer.borderColor = UIColor.systemGray4.cgColor
        editProfileStory.layer.cornerRadius = 5
        
        placeholderSetting()
        loadProfile()

    }
    
    func loadProfile() {
        editProfileImage.image = user?.profileImage != nil ? user?.profileImage! : defaultProfileImage!
        editName.text = user?.name
        print(user?.name)
        editNickName.text = user?.nickName
        editEmail.text = user?.email
        editProfileStory.text = "Description"
    }
    
    func placeholderSetting() {
        editProfileStory.delegate = self // txtvReview가 유저가 선언한 outlet
        editProfileStory.text = "Description"
        editProfileStory.textColor = UIColor.systemGray3
            
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
        guard let nickNameString = editNickName.text else { return false }
        guard let passwordString = editPassword.text else { return false }
        if nickNameString == "" {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func pickImage(tapGestureRecognizer: UITapGestureRecognizer){
        self.present(self.imagePicker, animated: true)
    }
    
    @IBAction func pressSaveButton(_ sender: UIButton) {
        guard verifyCorrectInputFormat() else { return }
        //uploadProfileImage(img: editProfileImage.image!)
        
        
        //Save User.init
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
        
        self.editProfileImage.image = newImage // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        
    }
}
