//
//  FeedViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/06.
//

import UIKit

class FeedViewController: UIViewController {
 
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
        
        
        editProfileButton.layer.borderColor = UIColor.gray.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 8
        
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedCell")
        
        //feedCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        //feedCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "default")
        //feedCollectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedCollectionHeader")
        
        
        setupFlowLayout()
        
        
    }
    
    
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        
        let halfWidth = (feedCollectionView.bounds.width - 4) / 3
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfWidth)
        self.feedCollectionView.collectionViewLayout = flowLayout
        
        //flowLayout.headerReferenceSize = CGSize(width: self.feedCollectionView.frame.size.width, height: 200)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 20
        return CGSize(width: width, height: height)
    }

    
}
