//
//  SocialViewController.swift
//  Pace Maker
//
//  Created by 성준오 on 2021/05/27.
//

import UIKit

class SocialViewController: UIViewController {

    @IBOutlet weak var imgview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let profileEX = UIImage(named: "workout")!
        print("here")
        uploadProfileImage(img: profileEX)
        getProfileImage(imgview: imgview)
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
