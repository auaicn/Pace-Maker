//
//  RunningResultViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/09.
//

import UIKit

class RunningResultViewController: UIViewController {
    
    var time: Int? = nil
    var distance: Double? = nil
    var currentTime: Date = Date()
    var routeImage: UIImage? = nil

    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
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
        routeImageView.image = routeImage
        distanceLabel.text = "\(distance) 킬로미터"
        timeElapsedLabel.text = "\(time / 60)분 \(time % 60) 초"
        let paceInSeconds = Int(Double(time) / distance)
        paceLabel.text = "\(paceInSeconds / 60)분 \(paceInSeconds % 60)"
    }
    
}
