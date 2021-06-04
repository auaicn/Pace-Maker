//
//  SocialViewController.swift
//  Pace Maker
//
//  Created by 성준오 on 2021/06/03.
//

import UIKit
import Firebase

class SocialViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var socialCollectionView: UICollectionView!
    
    var logOfFriends: [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadFriends()
        self.setupFlowLayout()
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialCell", for: indexPath) as?
                    socialFeedCell else {
                return UICollectionViewCell()
            }
        let img = UIImage(named: "feed-1")
                cell.imgView?.image = img
                cell.label?.text = "not yet bro"
        return cell
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        let halfWidth = (socialCollectionView.bounds.width)
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfWidth)
        self.socialCollectionView.collectionViewLayout = flowLayout
    }
    
    //Load Friends List From Firebase
    //Default User's ID is 1
    func loadFriends() {
        let refer = realReference.reference(withPath: "user")
        
        refer.child("1").child("friends").observe(.value){
            snapshot in
            let friends = snapshot.value as! [Int]
            self.loadLogsOfFriends(friends)
        }
    }
    
    //Load Logs Of Friends
    func loadLogsOfFriends(_ friends:[Int]){
        let refer = realReference.reference(withPath: "log")
        let logOrderByDate = refer.queryOrdered(byChild: "date")
        
        logOrderByDate.observe(.value, with: {snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                let val = child.childSnapshot(forPath: "runner").value as! Int
                if friends.contains(val) {
                    self.logOfFriends.append(child)
                }
            }
        })
    }
}

class socialFeedCell: UICollectionViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
}


