//
//  ViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/08.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sendDistanceLabel : UITextField!
    @IBOutlet weak var sendTimeLabel : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RouteViewController {
            let sendDistance = sendDistanceLabel.text
            let sendTime = sendTimeLabel.text
            vc.routeData.distance = sendDistance!
            vc.routeData.timeSpentInSeconds = sendTime!
        }
    }
}

