//
//  RouteSelectViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/27.
//

import UIKit

class RouteSelectViewController: UIViewController {
    
    var routes: [Route] = []
    var indexToDateString: [String] = []
    var routesByGroup: [String:[Route]] = [:]
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        loadLogs()
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
    
    func loadLogs(){
        let logReference = realReference.reference(withPath: "log")
        logReference.queryOrdered(byChild: "runner")
            .queryEqual(toValue: user?.UID)
            .observe(.value) { snapshot in
                let snapshot = snapshot.value as? [String : AnyObject] ?? [:]
                self.routes.removeAll()
                // snapshot is an Array of Dictionary
                for logDictonary in snapshot {
                    let singleLog = logDictonary.value
                    let date: String = singleLog["date"] as! String
                    let distance: Double = singleLog["distance"] as! Double
                    let route: String = singleLog["route"] as! String
                    let runner: Int = singleLog["runner"] as! Int
                    let time: Double = singleLog["time"] as! Double
                    self.routes.append(Route(dateString: date, distanceInKilometer: distance, routeSavedPath: route, runnerUID: runner, timeSpentInSeconds: time))
                }
                self.groupRoutesByDate()
                self.tableView.reloadData()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? RouteDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let dateString = indexToDateString[indexPath.section]
            let selectedRoute = routesByGroup[dateString]![indexPath.row]
            nextViewController.route = selectedRoute
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteSelectCell",for: indexPath)
        let route = routesByGroup[indexToDateString[indexPath.section]]![indexPath.row]
        cell.textLabel?.text = "\(route.dateString) \(String(format: "%.2f", route.distanceInKilometer))km"
        return cell
    }
}
