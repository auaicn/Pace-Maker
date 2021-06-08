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
    
    var infoOfFriends: [DataSnapshot] = []
    var logOfFriends: [DataSnapshot] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLogsOfFriends()
        self.setupFlowLayout()
        print(self.logOfFriends.count)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.logOfFriends.count)
        return self.logOfFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialCell", for: indexPath) as?
                    socialFeedCell else {
                return UICollectionViewCell()
            }
        
        cell.contentView.layer.masksToBounds = true
        
        let img = UIImage(named: "feed-1")
        cell.imgView?.image = img
        let tmpLog = logOfFriends[indexPath.row]
        let nick = tmpLog.childSnapshot(forPath: "nick").value as! String
        let date = tmpLog.childSnapshot(forPath: "date").value as! String
        var distance = tmpLog.childSnapshot(forPath: "distance").value as! Float64
        distance = round(distance * 1000) / 1000
        var time = tmpLog.childSnapshot(forPath: "time").value as! Float64
        time = round(time * 1000) / 1000
        cell.label.numberOfLines = 3
        cell.label.text = " \(nick) \(date) \n 달린거리: \(distance) (km) \n 달린시간: \(time) (seconds)"
        return cell
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        let width = socialCollectionView.bounds.width
        let space = width / 20
        flowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        let halfWidth =  (socialCollectionView.bounds.width - space * 2)
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfWidth)
        self.socialCollectionView.collectionViewLayout = flowLayout
    }
    
    //Load Logs Of Friends
    private func loadLogsOfFriends(){
        let refer = realReference.reference(withPath: "log")
        let logOrderByDate = refer.queryOrdered(byChild: "date")
        logOrderByDate.observe(.value, with: {snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                let val = child.childSnapshot(forPath: "runner").value as! Int
                if ((user?.friends.contains(val)) != nil) {
                    self.logOfFriends.append(child)
                }
            }
            print("here")
            self.socialCollectionView.reloadData()
            print("here done")
        })
        
    }
    
}

class socialFeedCell: UICollectionViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
}


