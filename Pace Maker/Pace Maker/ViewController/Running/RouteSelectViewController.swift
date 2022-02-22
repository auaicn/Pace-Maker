//
//  RouteSelectViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/27.
//

import UIKit
import Firebase

class RouteSelectViewController: UIViewController {
    
    var routes: [Log] = []
    var routesBySelf: [Log] = []
    var indexToDateString: [String] = []
    var routesByGroup: [String:[Log]] = [:]
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var encourageMessage: UILabel!
    @IBOutlet weak var bestRecordLabel: UILabel!
    @IBOutlet weak var latestRecordLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
         loadLogs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // loadLogs()
    }
    
    func setNavigationBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        setPullToRefresh()
    }
    
    func setPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func groupRoutes() {
        groupRoutesByDate()
        groupRoutesByMonth()
        groupRoutesByName()
    }
    
    func groupRoutesByName(){
        
    }

    
    func groupRoutesByDate(){
        routesByGroup.removeAll()
        indexToDateString.removeAll()
        for route in routes {
            let date = route.dateString
            if routesByGroup[date] == nil {
                indexToDateString.append(date)
                routesByGroup[date] = [route]
            }else{
                routesByGroup[date]?.append(route)
            }
        }
        indexToDateString = indexToDateString.sorted(by: >)
    }
    
    func groupRoutesByMonth(){
        routesByGroup.removeAll()
        indexToDateString.removeAll()
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let calendar = Calendar.current

        for route in routes {
            let date: Date = dateFormatter.date(from: route.dateString)!
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MM"
            let monthString = calendar.monthSymbols[(Int(monthFormatter.string(from: date)) ?? 1) - 1]
            
            if routesByGroup[monthString] == nil {
                indexToDateString.append(monthString)
                routesByGroup[monthString] = [route]
            }else{
                routesByGroup[monthString]?.append(route)
            }
        }
        indexToDateString = indexToDateString.sorted(by: >)
    }
    
    func loadLogs(){
        guard let user = user else { return }
        
        let logReference = realtimeReference.reference(withPath: "log")
        logReference.queryOrdered(byChild: "date")
            .observe(.value) { snapshot in
                let snapshot = snapshot.value as? [String : AnyObject] ?? [:]
                 print("LOGS snapshot.count",snapshot.count)
                
                self.routes.removeAll()
                for (logId,log) in snapshot {
                    
                    let date: String = log["date"] as! String
                    let distance: Double = log["distance"] as! Double
                    let route: String = log["route"] as! String
                    let time: Double = log["time"] as! Double
                    let nickname: String = log["nick"] as! String
                    
                    let runnerId: String = log["runner"] as! String
                    
                    let fetchedLog = Log(dateString: date, distanceInKilometer: distance, routeSavedPath: route, runnerUID: runnerId, nickname: nickname, timeSpentInSeconds: time)
                    
                    if runnerId == user.UID {
                        self.routesBySelf.append(fetchedLog)
                    } else {
                        self.routes.append(fetchedLog)
                    }
                }
                self.updateUI()
            }
    }
    
    func updateUI() {
        groupRoutes()
        tableView.reloadData()
        
        if routesBySelf.count != 0 {
            // 최고 기록
            guard let paceInSeconds = routesBySelf.max (by: { lhs, rhs in
                return lhs.pace > rhs.pace
            })?.pace else { return }
            bestRecordLabel.text = "\(paceInSeconds / 60) \(paceInSeconds % 60)"
            
            // 최근 기록
            guard let latestRecordPaceInSeconds = routesBySelf.last?.pace else { return }
            latestRecordLabel.text = "\(latestRecordPaceInSeconds / 60) \(latestRecordPaceInSeconds % 60)"
        }else {
            bestRecordLabel.text = "- : --"
            latestRecordLabel.text = "- : --"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? RouteDetailViewController{
           if let indexPath = tableView.indexPathForSelectedRow {
                let dateString = indexToDateString[indexPath.section]
                let selectedRoute = routesByGroup[dateString]![indexPath.row]
                
                nextViewController.log = selectedRoute
           }else {
                if routesByGroup.count != 0 {
                    nextViewController.log = routesBySelf.max(by: { lhs, rhs in
                        lhs.pace < rhs.pace
                    })
                }
           }
        }
    }
}

extension RouteSelectViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return routesByGroup.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routesByGroup[indexToDateString[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexToDateString[section]
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textAlignment = .right
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "총 : \(String((routesByGroup[indexToDateString[section]] ?? []).count) )"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutesTableViewCell",for: indexPath)
        let route = routesByGroup[indexToDateString[indexPath.section]]![indexPath.row]
        cell.textLabel?.text = "\(route.nickname)"
        cell.detailTextLabel?.text = "\(route.paceString)"
        
        return cell
    }
}
