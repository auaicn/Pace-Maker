//
//  CollectionHeader.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/14.
//

import UIKit

class CollectionHeader: UICollectionReusableView {
        
    @IBOutlet weak var editProfileButton: UIButton!
    
    func viewDidLoad() {
        editProfileButton.layer.borderColor = UIColor.gray.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
