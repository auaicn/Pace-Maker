//
//  CompetitorViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/27.
//

import UIKit

enum Category: String {
    case myself = "myself"
    case celebrities = "celebrities"
    case friends = "friends"
}

class CompetitorViewController: UIViewController {
    
    let categoryWithIndex: [Category] = [Category.myself,Category.celebrities,Category.friends]
    var followers: [String:[String:String]] = [Category.myself.rawValue:[user!.name:user!.UID] ,
                                            Category.celebrities.rawValue:[:],
                                            Category.friends.rawValue:[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDatabase()
        // Do any additional setup after loading the view.
    }
    
    func loadDatabase() {
        print(user?.friends)
        loadFriends()
    }
    
    func loadFriends(){
        guard let friends = user?.friends else {return}
        followers[Category.friends.rawValue]?.removeAll()
        for friend in friends {
            followers[Category.friends.rawValue]?["name"] = friend
        }
    }
    
//    func loadFriends() {
//        let refer = realtimeReference.reference(withPath: "user")
//
//        refer.child(String(user!.UID)).child("friends").observe(.value){ snapshot in
//            let friends = snapshot.value as! [Int]
//            followers[Category.friends.rawValue]?.removeAll()
//            followers[Category.friends.rawValue]? = snapshot.value as! [Int]
//        }
//    }

}

// DATA SOURCE
extension CompetitorViewController :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers[categoryWithIndex[section].rawValue]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "follower",for: indexPath)
        
        let categoryValues = Array(followers.values)[indexPath.section]
        
        cell.textLabel!.text = "auaicn"
        return cell
//
//        let followerName = categoryValues
//        switch indexPath.section {
//            case 0:
//                cell.textLabel = user?.name
//                cell.detailTextLabel =
//            case 1:
//
//            case 2:
//
//            default:
//                print("error")
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: "follower",for: indexPath)
//
//        cell.textLabel = user?.friends[indexPath.row].
//        return cell

//        let categoryValue = followers
    }
    
    // ABOUT SECTION
    func numberOfSections(in tableView: UITableView) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(categoryWithIndex[section].rawValue)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionCount: Int = followers[categoryWithIndex[section].rawValue]?.count ?? 0
        return "\(sectionCount) 명"
    }
}
