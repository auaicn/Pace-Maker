//
//  FeedViewController.swift
//  Pace Maker
//
//  Created by 전연지 on 2021/05/06.
//

import UIKit

class FeedViewController: UIViewController {
 
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
    
        
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedCell")
        
      
        //feedCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        //feedCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "default")
        //feedCollectionView.register(CollectionReusableView.self, forSuppl ementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedHeader")
        feedCollectionView.register(UINib(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedHeader")
        
        setupFlowLayout()
        
        
    }
    
    
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        
        
        flowLayout.headerReferenceSize = CGSize(width: self.feedCollectionView.frame.size.width, height: 262)
        
        let width = UIScreen.main.bounds.size.width / 3 - 2
        flowLayout.itemSize = CGSize(width: width, height: width)
        self.feedCollectionView.collectionViewLayout = flowLayout
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.feedCollectionView.reloadData()
        print("reload")
    }

}

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, HeaderViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
    
        cell.imageView.image = feedStorys[indexPath.row]
        cell.configure()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 20
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeader", for: indexPath) as! CollectionReusableView
            // do any programmatic customization, if any, here
            header.configure()
            header.delegate = self
            return header
        }
        fatalError("Unexpected kind")
    }

    func touchEditButton() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfileViewController")
        //vc?.modalTransitionStyle = .coverVertical
        self.present(vc!, animated: true, completion: nil)
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "contentsSegue", sender: self)
    }
    
}
