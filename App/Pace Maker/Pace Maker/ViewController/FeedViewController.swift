//
//  FeedViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/06.
//

import UIKit

class FeedViewController: UIViewController {
 
    @IBOutlet weak var profile: UITextField!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    private var numberOfCell = 20 {
        didSet {
            if numberOfCell > 50 {
                numberOfCell = 50
            } else if
                numberOfCell < 0{
                numberOfCell = 0
            }
        }
    }
    
    private var feedStorys : [UIImage] {
        var feedStorys : [UIImage] = []
        for i in 1...50 {
            let index = i % 5 + 1
            let image = UIImage(named: "feed-\(index)")!
            feedStorys.append(image)
        }
        return feedStorys
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //editProfileButton.layer.borderColor = UIColor.white.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 8
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedCell")
        
        setupFlowLayout()
        
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        
        let halfWidth = feedCollectionView.bounds.width / 3
        flowLayout.itemSize = CGSize(width: halfWidth * 0.9 , height: halfWidth * 0.9)
        self.feedCollectionView.collectionViewLayout = flowLayout
    }
    
    @IBAction func tapEditProfileButton(_ sender: UIButton) {
        if profile.isUserInteractionEnabled == true {
            profile.isUserInteractionEnabled = false
        }
        else {
            profile.isUserInteractionEnabled = true
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

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
    
        cell.imageView.image = feedStorys[indexPath.row]
        return cell
    }
}
