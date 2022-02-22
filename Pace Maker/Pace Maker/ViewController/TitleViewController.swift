//
//  TabBarViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/30.
//

import UIKit

class TitleViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 2 // 탭바 레이아웃에서, 운동 화면을 기본 화면으로 설정한다.
        // Do any additional setup after loading the view.
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
