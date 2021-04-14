//
//  KDetailedTableCellViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/04/15.
//

import UIKit

class KDetailedTableCellViewController: UIViewController {
    
    var badge : Badge?

    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var badgeName: UILabel!
    @IBOutlet weak var badgeOwner: UILabel!
    @IBOutlet weak var badgeDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        badgeImage.image = badge?.image
        badgeName.text = badge?.name
        badgeOwner.text = "created by " + (badge?.owner ?? "unknown")
        badgeDescription.font = UIFont(name: "BinggraeMelona-Bold", size: 11)
        // Do any additional setup after loading the view.
    }
}
