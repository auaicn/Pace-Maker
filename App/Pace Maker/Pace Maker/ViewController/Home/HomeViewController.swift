//
//  CustomHomeViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/14.
//

import UIKit
class HomeViewController: UIViewController{

    func makeOverlayStartRunningButton() -> Void {
        let button = UIButton()
        button.addAction(UIAction(handler: {_ in self.startRunning(sender: button)}), for: .touchUpInside)
        
        print(self.view.frame.height)
        button.backgroundColor = UIColor(named: "AccentColor")
        
        let widthMultiplier : CGFloat = 0.9
        let aspectRatio : CGFloat = 6 / 1
        
        button.setTitle("러닝 시작하기", for: .normal)
        button.frame.size.width = self.view.frame.width * widthMultiplier
        button.frame.size.height = button.frame.size.width / aspectRatio
        button.frame.origin.x = self.view.frame.width * ((1-widthMultiplier)/2)
        button.frame.origin.y = self.view.frame.height - button.frame.size.height - 83 - 16
        
        // corner
        button.layer.cornerRadius = 20
        button.layer.opacity = 0.96
        
        // shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        view.addSubview(button)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeOverlayStartRunningButton()
        // Do any additional setup after loading the view.
    }
    
    func startRunning(sender :UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
                       },
                       completion: { Void in()  }
        )
        
        // let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil) <- 다른 스토리보드로의 이동을 원할때는 그렇게 사용가능하겠는데, 지금은 필요없을듯.
        if let nextVC = (storyboard?.instantiateViewController(identifier: "Running"))! as? RunningViewController{
            nextVC.modalTransitionStyle = .crossDissolve
            nextVC.modalPresentationStyle = .overCurrentContext
            
            self.navigationController?.pushViewController(nextVC, animated: true)
//            self.present(nextVC, animated:true, completion:nil)
        }
        
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
