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
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var syncBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var measureMessagePrefix: UILabel!
    @IBOutlet weak var measuredPeriod: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var measureUnit: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let syncMessage = UILabel(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
    
    // Data
    var logs: [Log] = []
    var heartRateData: [(date: Date, value: Double)] = []
    var activeEnergyBurnedData: [(date: Date, value: Double)] = []
    
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
                    let time: Double = singleLog["time"] as! Double
                    let nickname: String = singleLog["nick"] as! String
                    
                    let runnerId: Int = singleLog["runner"] as! Int
                    let runnerString = String(runnerId)
                    
                    self.logs.append(Log(dateString: date, distanceInKilometer: distance, routeSavedPath: route, runnerUID: runnerString, nickname: nickname, timeSpentInSeconds: time))
                }
                self.updateUI()
            }
    }
    
    /// initial setting for chart view
    func setChartView() {
        chartView.noDataTextColor = .lightGray
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
    }
    
    func updateBarChartData(with dataEntries:[(String,Double)]){
        if dataEntries.count == 0 { return }
        
        let data: CombinedChartData = CombinedChartData()
        
        data.calcMinMax()

        var barChartDataEntries: [BarChartDataEntry] = []
        for i in 0..<dataEntries.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: dataEntries[i].1)
            barChartDataEntries.append(dataEntry)
        }
        
        let barChartDataSet = BarChartDataSet(entries: barChartDataEntries, label: currentMetric.label)
        let barChartData = BarChartData(dataSet: barChartDataSet)
        chartView.data = barChartData
        
    }
    
    func updateLineChartData(with dataEntries:[(String,Double)]){
        if dataEntries.count == 0 { return }

        var lineChartDataEntries: [ChartDataEntry] = []
        for i in 0..<dataEntries.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: dataEntries[i].1)
            lineChartDataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(entries: lineChartDataEntries, label: currentMetric.label)
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        chartView.data = lineChartData
        
    }
    
    func updateChartUI(with dataEntries:[(String,Double)]){
        if dataEntries.count == 0 { return }
        
        let valueSum: Double = dataEntries.reduce(0) { $0 + $1.1 }
        let averageValue = valueSum / Double(dataEntries.count)
        let dates: [Date] = dataEntries.map {
            return dateFormatter.date(from: $0.0)!
        }
        
        // Chart 위에 레이블들 설정
        measureUnit.text = currentMetric.unit
        let distantDateString = dateFormatter.string(from: dates.min()!)
        let recentDateString = dateFormatter.string(from: dates.max()!)
        measuredPeriod.text = (distantDateString == recentDateString) ? distantDateString : "\(distantDateString) ~ \(recentDateString)"
        
        if currentMetric == .pace {
            // 최고기록을 뽑아낸다
            let bestRecord: Double = dataEntries.reduce(Double.greatestFiniteMagnitude) {
                ($0 < $1.1) ? $0 : $1.1
            }
            let pacesInSeconds = Int(bestRecord)
            summary.text = String(format: currentMetric.summaryFormat, pacesInSeconds/60, pacesInSeconds%60)
        }else {
            summary.text = String(format: currentMetric.summaryFormat, currentMetric == .distance ? valueSum : averageValue)
        }
        
        // in-Chart limit lines
        let averageLine = ChartLimitLine(limit: averageValue, label: currentMetric.limitLineLabel)
        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.addLimitLine(averageLine)
//        chartView.leftAxis.zeroLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        chartView.data?.dataSets.first?.setColor(currentMetric.colorSet)
        chartView.xAxis.labelPosition = .top // X축 레이블 위치 조정
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataEntries.map({$0.0})) // X축 레이블 포맷 지정
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.8)
    }
    
    func updateChart(){
        
        var chartEntries: [(String,Double)] = []
        switch currentMetric {
            case .distance:
                for log in logs{
                    chartEntries.append((log.dateString,log.distanceInKilometer))
                }
                updateBarChartData(with: chartEntries)
                updateChartUI(with: chartEntries)
            case .pace:
                for log in logs{
                    chartEntries.append((log.dateString, Double(log.pace)))
                }
                updateBarChartData(with: chartEntries)
                updateChartUI(with: chartEntries)
            case .heartRate:
                for heartRate in heartRateData {
                    chartEntries.append((dateFormatter.string(from: heartRate.date), heartRate.value))
                }
                updateLineChartData(with: chartEntries)
                updateChartUI(with: chartEntries)
            case .activeEnergyBurned:
                for activeEneryBurned in activeEnergyBurnedData {
                    chartEntries.append((dateFormatter.string(from: activeEneryBurned.date), activeEneryBurned.value))
                }
                updateLineChartData(with: chartEntries)
                updateChartUI(with: chartEntries)
        }
        // 그외 추가로 더 해줘야하는 것들
        measureMessagePrefix.text = currentMetric.prefix
        measureUnit.text = currentMetric.unit
    }
}

struct HKData{
    let loggedDate: Date
    let value: Double
}

// HEALTH KIT
extension ActivityViewController {
    
    func loadHealthKitData(){
        authorizeHealtKitData()
        requestHealthKitData()
    }
    
    func requestHealthKitData(){
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit Data not available")
            return
        }
        
        requestActiveEnergyBurnedData()
        requestHeartRateData()
    }
    
    func requestHeartRateData(){
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        getSamples(for: heartRate) { (samples: [HKSample]?, error : Error?) in
            if let _ = error { return }
            guard let samples = samples else { return }
            print("loaded \(samples.count) heartRate data")
            
            // remove unnecessory sample data. only extract date / heartrate value
            let samplesByDate = samples.map { sample -> HKData in
                guard let quantitySample: HKQuantitySample = sample as? HKQuantitySample else { return HKData(loggedDate: Date(), value: 0) }
                return HKData(loggedDate: quantitySample.startDate, value: quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
            }
            
            // group bpm value by date
            let calendar = Calendar.current
            let samplesGrouped = Dictionary(grouping: samplesByDate, by: {
                [calendar.component(.year, from: $0.loggedDate),
                 calendar.component(.month, from: $0.loggedDate),
                 calendar.component(.day, from: $0.loggedDate)]
            })
            print("samplesGrouped.count",samplesGrouped.count)
            
            // set datasource
            self.heartRateData = []
            for sampleOneDay in samplesGrouped {
                let date: Date = dateFormatter.date(from: "\(sampleOneDay.key[0])-\(sampleOneDay.key[1])-\(sampleOneDay.key[2])")!
                let heartRate: Double = sampleOneDay.value.reduce(0.0){$0 + $1.value} / Double(sampleOneDay.value.count)
                print(date, heartRate)
                self.heartRateData.append((date, heartRate))
            }
            self.heartRateData.sort { $0.date < $1.date }
        }
    }
    
    func requestActiveEnergyBurnedData(){
        guard let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        getSamples(for: activeEnergy) { (samples: [HKSample]?, error : Error?) in
            if let _ = error { return }
            guard let samples = samples else { return }
            print("loaded \(samples.count) active enery burned data")
            
            // remove unnecessory sample data. only extract date / kilocalories value
            let samplesByDate = samples.map { sample -> HKData in
                guard let quantitySample: HKQuantitySample = sample as? HKQuantitySample else { return HKData(loggedDate: Date(), value: 0) }
                return HKData(loggedDate: quantitySample.startDate, value: quantitySample.quantity.doubleValue(for: HKUnit.kilocalorie()))
            }
            
            // group kilocalories value by date
            let calendar = Calendar.current
            let samplesGrouped = Dictionary(grouping: samplesByDate, by: {
                                    [calendar.component(.year, from: $0.loggedDate),
                                     calendar.component(.month, from: $0.loggedDate),
                                     calendar.component(.day, from: $0.loggedDate)]
            })
            print("samplesGrouped.count",samplesGrouped.count)
            
            // set datasource
            self.activeEnergyBurnedData = []
            for sampleOneDay in samplesGrouped {
                let date:Date = dateFormatter.date(from: "\(sampleOneDay.key[0])-\(sampleOneDay.key[1])-\(sampleOneDay.key[2])")!
                let kiloCalories = sampleOneDay.value.reduce(0.0){$0 + $1.value}
                self.activeEnergyBurnedData.append((date, kiloCalories))
            }
            self.activeEnergyBurnedData.sort { $0.date < $1.date }
        }
    }
    
    func getSamples(for sampleType: HKSampleType, completion: @escaping ([HKSample]?, Error?) -> Swift.Void) {
        // 1. Use HKQuery to load the most recent samples.
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            // 2. Always dispatch to the main thread when complete.
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
    
//    func saveDistanceWalkingRunning(){
//        let healthStore = HKHealthStore()
//
//        if let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)){
//
//        }
//    }
    
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
