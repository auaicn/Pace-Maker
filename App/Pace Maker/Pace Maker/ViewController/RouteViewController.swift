//
//  RouteViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/08.
//

import UIKit

class RouteViewController: UIViewController {
    
    var routeData : Route = Route(distance: "distance", timeSpentInSeconds: "time")
    
    @IBOutlet weak var distanceLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        distanceLabel.text = "거리 : \(routeData.distance)"
        timeLabel.text = "시간 : \(routeData.timeSpentInSeconds)"
    }

}
