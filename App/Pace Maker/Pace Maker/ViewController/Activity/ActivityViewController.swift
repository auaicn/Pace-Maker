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

class ActivityViewController: UIViewController {

    @IBOutlet weak var deviceNotAvailableLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var syncBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var measureMessagePrefix: UILabel!
    @IBOutlet weak var measuredPeriod: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var measureUnit: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let syncMessage = UILabel(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
    
    // Data
    var logs: [Route] = []
//    var heartRateData: HKSampleType? = nil
//    var heartRateData: HKQuantitySample? = HKQuantitySample(type: ., quantity: , start: .distantPast, end: .distantFuture)
//    var activeEnergyBurnedData: HKSampleType? = nil
    
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
        self.tableView.reloadData()
    }
    
    @IBAction func changedSegmentControlValue(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
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
                self.updateUI()
            }
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
        if dateStrings.count == 0 || values.count == 0 { return }
        
        let valueSum: Double = values.reduce(0) { $0 + $1 }
        let averageValue = valueSum / Double(dateStrings.count)
        let dates: [Date] = dateStrings.map {
            return dateFormatter.date(from: $0)!
        }
        
        // Chart 위에 레이블들 설정
        measureUnit.text = currentMetric.unit
        let distantDateString = dateFormatter.string(from: dates.min()!)
        let recentDateString = dateFormatter.string(from: dates.max()!)
        measuredPeriod.text = (distantDateString == recentDateString) ? distantDateString : "\(distantDateString) ~ \(recentDateString)"
        
        if currentMetric == .pace {
            let pacesInSeconds = Int(values.max()!) // 함수 초입에서 count 가 0 인지 확인해서 괜찮다.
            summary.text = String(format: currentMetric.summaryFormat, pacesInSeconds/60, pacesInSeconds%60)
        }else {
            summary.text = String(format: currentMetric.summaryFormat, currentMetric == .distance ? valueSum : averageValue)
        }
        
        // Chart
        let averageLine = ChartLimitLine(limit: averageValue, label: "평균")
        barChartView.leftAxis.addLimitLine(averageLine)
        
    }
    
    func updateChart(){
        
        var dates: [String] = []
        var values: [Double] = []
        switch currentMetric {
            case .distance:
                for log in logs{
                    dates.append(log.dateString)
                    values.append(log.distanceInKilometer)
                }
                if logs.count != 0 {
                    setChartData(with: dates, and: values)
                    setChartUI(with: dates, and: values)
                }
            case .pace:
                for log in logs{
                    dates.append(log.dateString)
                    values.append(Double(log.pace))
                }
                if logs.count != 0 {
                    setChartData(with: dates, and: values)
                    setChartUI(with: dates, and: values)
                }
            case .heartRate:
                let i = 1
            case .activeEnergyBurned:
                let i = 1
        }
        // 그외 추가로 더 해줘야하는 것들
        measureMessagePrefix.text = currentMetric.prefix
        measureUnit.text = currentMetric.unit
    }
}

// HEALTH KIT
extension ActivityViewController {
    
    func loadHealthKitData(){
        authorizeHealtKitData()
        requestHealthKitData()
    }
    
    func requestHealthKitData(){
//        loadHeertRateData()
//        loadActiveEnergyBurnedData()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit Data not available")
//            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
              let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            print("HealthKit Data Type Setting not available")
            return
        }
        
        getMostRecentSample(for: activeEnergy) { (samples: [HKSample]?, error : Error?) in
            if let error = error {
                print("getMostRecentSample error")
                print(error)
                return
            }
            guard let samples = samples else {
                print("No data available")
                return
            }
            print("samples.count", samples.count)
            for sample in samples{
                guard let ch:HKQuantitySample = sample as? HKQuantitySample else { return }
//                print(quantitySample.quantity)
//                quantitySample.startDate
                    
//                let calorie = sample.val .doubleValue(for: HKUnit.kilocalorie())
//                print("calorie",calorie)
            }
            return
        }
    }
    
    func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping ([HKSample]?, Error?) -> Swift.Void) {
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                guard let samples = samples else {
                    completion(nil, error)
                    return
                }
                completion(samples, nil)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    func loadHeertRateData(){
        
    }
    
    func saveDistanceWalkingRunning(){
        let healthStore = HKHealthStore()
        
//        if let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)){
//
//        }
    }
    
    func loadActiveEnergyBurnedData(){
        
    }
    
    func authorizeHealtKitData() {
        
        let healthStore = HKHealthStore()

        if HKHealthStore.isHealthDataAvailable() {
            
            let readTypes = Set([HKObjectType.workoutType(),
                                 HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                 HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                 HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                 HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                 HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            ])

            let writeTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
            
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                }
            }
        }else {
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
extension ActivityViewController :UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentMetric {
            case .distance:
                return logs.count
            case .pace:
                return logs.count
            case .heartRate:
                return 0
//                return heartRateData.count
            case .activeEnergyBurned:
                return 0
//                return activeEnergyBurnedData.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentMetric {
            case .distance:
                let cell = tableView.dequeueReusableCell(withIdentifier: "distance", for: indexPath)
                let log = logs[indexPath.row]
                cell.textLabel?.text = String(format: "%.2f", log.distanceInKilometer)
                cell.detailTextLabel?.text = log.dateString
                return cell
            case .pace:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pace", for: indexPath)
                let log = logs[indexPath.row]
                cell.textLabel?.text = log.paceString
                cell.detailTextLabel?.text = log.dateString
                return cell
            case .heartRate:
                let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath)
                return cell
            case .activeEnergyBurned:
                let cell = tableView.dequeueReusableCell(withIdentifier: "activeEnergyBurned", for: indexPath)
                return cell
        }
    }
    
    
}
