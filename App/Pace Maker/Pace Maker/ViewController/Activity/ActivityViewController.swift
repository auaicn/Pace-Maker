//
//  ActivityViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/20.
//

import UIKit
import HealthKit
import Charts
import Firebase

enum CurrentMetric{
    case speed, respiration, beatsPerMinute, fourth
    
    var unit: String {
        switch self{
            case .speed:
                return "m/s"
            case .respiration:
                return "per minute"
            case .beatsPerMinute:
                return "per minute"
            case .fourth:
                return "fourth Unit"
        }
    }
}

let currentMetric: CurrentMetric = .speed

class ActivityViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var deviceNotAvailableLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var syncBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var totalMetrics: UILabel!
    @IBOutlet weak var unitOfMetric: UILabel!
    
    let syncMessage = UILabel(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
    let logs: [Route] = []
    
    func setNavigationBar() {
        refreshBarButtonItem.action = #selector(tappedRefreshBarButton)
        syncMessage.backgroundColor = .blue
        syncBarButtonItem.customView?.addSubview(syncMessage)
        syncMessage.text = "sync 1d ago..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 0 // speed
        setNavigationBar()
        authorizeHealtKitData()
        setChartView()
        updateUI()
    }

    @objc
    func tappedRefreshBarButton() {
        print("tappedRefreshBarButton")
        updateUI()
    }
    
    func updateUI() {
        updateChart()
        unitOfMetric.text = currentMetric.unit
    }
}



extension ActivityViewController {
    
    func loadLogs(){

        let logReferenceAsQuery = realReference.reference(withPath: "user").queryOrderedByKey()
        
        logReferenceAsQuery.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
                return;
            }
            else if snapshot.exists() {
//                print("Got data \(snapshot.value!)")
//                
//                let logs = snapshot.value as? [String : AnyObject] ?? [:]
//                
//                print(logs["1"])
//
//                let addr: String = userDictionary["addr"] as! String
//                let age: Int = userDictionary["age"] as! Int
//                let challenges: [Int] = userDictionary["challenges"] as! [Int]
//                let friends: [Int] = userDictionary["friends"] as! [Int]
//                let email: String = userDictionary["email"] as! String
//                let name: String = userDictionary["name"] as! String
//                let nick: String = userDictionary["nick"] as! String
//                let passwd: String = userDictionary["passwd"] as! String
//                let phone: String = userDictionary["phone"] as! String
//
//                Route(dateString: <#T##String#>, distanceInKilometer: <#T##Double#>, routeSavedPath: <#T##String#>, runnerUID: <#T##Int#>, timeSpentInSeconds: <#T##Double#>)
//
//                user = User(UID: id, name: name, email: email, age: age, nickName: nick, challenges: challenges, friends: friends)
//                self.updateAuthenticationStatus(to: .loggined)
//
//                print("logined with UID \(id)")
                
//                user = User(UID: 3, name: "", email: inputEmail, age: 22, nickName: "", challenges: [], friends: [])
            }
            else {
                print("No data available")
            }
        }
    }
    
    func setChartView() {
        
        loadLogs()
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setChartData(dataPoints: months, values: unitsSold)
        
        barChartView.noDataTextColor = .lightGray
        barChartView.rightAxis.enabled = false
        
    }
    
    func setChartData(dataPoints: [String], values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "판매량")
        
        // 차트 컬러
        chartDataSet.colors = [.systemBlue]
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
    func updateChart(){
        
    }
}

extension ActivityViewController {
    
    func authorizeHealtKitData() {
        
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            
            let readTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                 HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                 HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                                 HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                                 HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                 HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                 HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            ])
            
            let writeTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
            
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("healthkit authroization error")
                }
            }
        } else {
            // iOS 8 이상에서만 건강 앱과 관련된 작동이 가능하다
            for s in view.subviews {
                s.isHidden = true
            }
            deviceNotAvailableLabel.isHidden = false
        }
        
    }
}

