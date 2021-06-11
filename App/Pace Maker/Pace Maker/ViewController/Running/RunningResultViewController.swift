//
//  RunningResultViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/09.
//

import UIKit

class RunningResultViewController: UIViewController {
    
    let currentTime: Date = Date()
    
    var time: Int? = nil
    var distance: Double? = nil
    var routeImage: UIImage? = nil

    @IBOutlet weak var routeImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateUI()
    }
    
    func updateUI() {
        guard let time = time,
              let distance = distance,
              let routeImage = routeImage else { return }
        // set image
        routeImageView.image = routeImage
        
        // set labels
        distanceLabel.text = "\(String(format:".2f",distance)) 킬로미터"
        timeLabel.text = "\(time / 60)분 \(time % 60) 초"
        let paceInSeconds = distance != 0 ? Int(Double(time) / distance) : 0
        paceLabel.text = "\(paceInSeconds / 60):\(paceInSeconds % 60)"
    }
    
}
