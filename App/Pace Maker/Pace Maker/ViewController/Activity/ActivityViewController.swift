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

enum CurrentMetric: String{
    case distance, pace, beatsPerMinute, respiration
    
    static let allValues = [distance, pace, beatsPerMinute, respiration]
    
    var unit: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s per km"
            case .beatsPerMinute:
                return "per minute"
            case .respiration:
                return "per minute"
        }
    }
    
    var label: String {
        switch self{
            case .distance:
                return "km"
            case .pace:
                return "m:s per km"
            case .beatsPerMinute:
                return "per minute"
            case .respiration:
                return "per minute"
        }
    }
    
    var prefix: String {
        switch self{
            case .distance:
                return "총"
            case .pace:
                return "최대"
            case .beatsPerMinute:
                return ""
            case .respiration:
                return ""
        }
    }
    
}

var currentMetric: CurrentMetric = .distance

class ActivityViewController: UIViewController {

    @IBOutlet weak var deviceNotAvailableLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var syncBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var measureMessagePrefix: UILabel!
    @IBOutlet weak var measuredPeriod: UILabel!
    @IBOutlet weak var measuredTotalValue: UILabel!
    @IBOutlet weak var measureUnit: UILabel!
    
    let syncMessage = UILabel(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
    var logs: [Route] = []
    
    func setNavigationBar() {
        // later
        syncMessage.backgroundColor = .blue
        syncBarButtonItem.customView?.addSubview(syncMessage)
        syncMessage.text = "sync 1d ago..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setChartView()
        loadDatabase()
        updateUI()
    }
    
    func loadDatabase() {
        loadLogs() // load data
        loadHealthKitData()
        loadWatchKitData()
    }
    
    func updateUI() {
        updateChart()
        updateTable()
    }
    
    func updateTable(){
        
    }
    
    @IBAction func changedSegmentControlValue(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        print("selected \(selectedIndex) th semgent")
        currentMetric = CurrentMetric.allValues[selectedIndex]
        updateUI()
    }
}

// CHART
extension ActivityViewController {
    
    func loadLogs(){
        let logReference = realReference.reference(withPath: "log")
        logReference.queryOrdered(byChild: "runner")
            .queryEqual(toValue: user?.UID)
            .observe(.value) { snapshot in
                let snapshot = snapshot.value as? [String : AnyObject] ?? [:]
                self.logs.removeAll()
                // snapshot is an Array of Dictionary
                for logDictonary in snapshot {
                    let singleLog = logDictonary.value
                    let date: String = singleLog["date"] as! String
                    let distance: Double = singleLog["distance"] as! Double
                    let route: String = singleLog["route"] as! String
                    let runner: Int = singleLog["runner"] as! Int
                    let time: Double = singleLog["time"] as! Double
                    self.logs.append(Route(dateString: date, distanceInKilometer: distance, routeSavedPath: route, runnerUID: runner, timeSpentInSeconds: time))
                }
                print("1")
                self.updateUI()
            }
        print("2")
    }
    
    func setChartView() {
        barChartView.noDataTextColor = .lightGray
        barChartView.rightAxis.enabled = false
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 3.0)
    }
    
    func setChartData(with dates: [String],and values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dates.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: currentMetric.label)
        chartDataSet.colors = [.systemRed,.systemBlue,.systemTeal]
        barChartView.data = BarChartData(dataSet: chartDataSet)
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
    }
    
    func setChartUI(with dateStrings: [String],and values: [Double]){
        let totalDistance: Double = values.reduce(0) { $0 + $1 }
        let dates: [Date] = dateStrings.map {
            return dateFormatter.date(from: $0)!
        }
        
        measuredTotalValue.text = String(format: "%.2f", totalDistance)
        measureUnit.text = currentMetric.unit
        if dateStrings.count != 1 {
            measuredPeriod.text = "\(dateFormatter.string(from: dates.min()!)) "
        }else{
            measuredPeriod.text = "\(dateFormatter.string(from: dates.min()!)) ~ \(dateFormatter.string(from: dates.max()!))"
        }
        
        let averageLine = ChartLimitLine(limit: totalDistance / Double(dateStrings.count), label: "평균")
        barChartView.leftAxis.addLimitLine(averageLine)
        
    }
    
    func updateChart(){
        
        var dates: [String] = []
        var values: [Double] = []
        for log in logs{
            dates.append(log.dateString)
            values.append(log.distanceInKilometer)
        }
        
        if logs.count != 0 {
            setChartData(with: dates, and: values)
            setChartUI(with: dates, and: values)
        }
        
        // 그외 추가로 더 해줘야하는 것들
        measureUnit.text = currentMetric.unit
    }
}

// HEALTH KIT
extension ActivityViewController {
    
    func loadHealthKitData(){
        authorizeHealtKitData()
    }
    
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

// WATCH KIT
extension ActivityViewController {
    func loadWatchKitData(){
        
    }
}

// TABLE VIEW
extension ActivityViewController {
    
}
