//
//  FeedCell.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/08.
//

import UIKit

class FeedCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure() {
        imageView.contentMode = .scaleAspectFill
    }

}
