//
//  editProfileViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/23.
//

import UIKit


class editProfileViewController: UIViewController, UITextViewDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var profileStory: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var profileStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        profileImage.isUserInteractionEnabled = true
        
        saveButton.isEnabled = false

        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = true // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
        // Do any additional setup after loading the view.
        
        let nowImage = (UIImage(named: "2"))
                            //?.withRenderingMode(.alwaysOriginal))!
        
        profileImage.image = nowImage
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        
        profileStory.delegate = self
        profileStory.text = "story"
        self.profileStory.layer.borderWidth = 1.0
        self.profileStory.layer.borderColor = UIColor.black.cgColor

        
        //profileStack.addArrangedSubview(profileImage)
        

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

}

extension editProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        
        self.profileImage.image = newImage // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        
    }
}
