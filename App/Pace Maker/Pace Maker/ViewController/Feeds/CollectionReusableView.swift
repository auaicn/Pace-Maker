//
//  CollectionReusableView.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/27.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func touchEditButton()
}

class CollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var badge: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var discription: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: HeaderViewDelegate?
       
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
       
    func configure() {
        
        feedImage.image = user?.profileImage != nil ? user?.profileImage! : defaultProfileImage!
        feedImage.contentMode = .scaleAspectFill
        feedImage.layer.cornerRadius = feedImage.frame.width / 2
        feedImage.clipsToBounds = true
        
        distance.text = "총 달린 거리 : "
        time.text = "총 달린 시간 : "
        badge.text = "획득 뱃지 : "
        following.text = "팔로잉 : "
        discription.text = user?.discription != nil ? user?.discription! : ""
        
        editButton.layer.borderColor = UIColor.gray.cgColor
        editButton.layer.borderWidth = 1
        editButton.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
       
    @IBAction func touchEditButton(_ sender: UIButton) {
        delegate?.touchEditButton()
    }
    
     required init?(coder: NSCoder) {
         super.init(coder: coder)
     }
}
