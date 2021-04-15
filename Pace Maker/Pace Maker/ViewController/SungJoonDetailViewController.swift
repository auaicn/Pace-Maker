//
//  SungJoonDetailViewController.swift
//  Pace Maker
//
//  Created by 성준오 on 2021/04/15.
//

import UIKit

class SungJoonDetailViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var textview: UITextView!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        name.text = user.name
        info.text = user.info
        //textview.text = user.info
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
