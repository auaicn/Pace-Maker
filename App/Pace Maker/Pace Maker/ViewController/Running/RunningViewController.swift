//
//  RunningViewController.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/05/03.
//

import UIKit
import MapKit
import CoreLocation
import CoreGPX
import Firebase
import NotificationBannerSwift

class RunningViewController: UIViewController {
    
    // fetched from previous view
    var competitorLog: Log? = nil
    var goalPace: Int? = nil
    var goalDistance: Double? = nil
    var goalElapsedTime: Double? = nil
    
    // display
    var movedDistance: Double = 0
    var timeElapsed: Int = 0
    
    // flag
    var startedRunning: Bool = false // set true when started running
    var isRunning : Bool = false; // used for button
    
    // to send
    var screenshotImage: UIImage? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var movedDistanceLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var goalPaceLabel: UILabel!
    
    @IBOutlet weak var startPauseImage: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isVoicehapticfeedbackGeneratorEnabled: Bool = false
    var isVoiceRecordingEnabled: Bool = false
    var isAutoStopEnabled: Bool = false
    var isTrackingStarted: Bool = false
    
    var previousLocation :CLLocation?
    var locationManager : CLLocationManager = CLLocationManager()
    let regionMeters: Double = 1000
    
    let alert = UIAlertController(title: "권한 오류", message: "위치 정보 사용이 필요합니다.", preferredStyle: .alert)
    
    var root = GPXRoot(creator: "Pace Maker") // insert your app name here
    var trackpoints = [GPXTrackPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setMapView()
        setNavigationBar()
        checkLocationServices()
        setDefaultUI()
        
        // other settings
        currentPaceLabel.text = "- : --"
    }
    
    func setDefaultUI() {
        movedDistance = 0
        timeElapsed = 0
        if goalPace != nil {
            goalPaceLabel.text = "목표 페이스 \(goalPace! / 60) : \(goalPace! % 60)"
        }
        updateUI()
    }
    
    @IBAction func didLongPressRunningButton(_ sender: Any) {
        print("long pressed")
        if isRunning {
            isRunning = false
            if startedRunning {
                finishRunning()
            }
        }
    }
    
    func setMapView() {
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .dark
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)! // follows heading!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        guard let location = previousLocation else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func startRunning() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        banner3.show()
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleTimerEvent), userInfo: nil, repeats: true)
    }
 
    func stopRunning(){
        banner3.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self)
        hapticfeedbackGenerator.notificationOccurred(.error)
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func resumeRunning() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func uploadLog(with fileName: String){
        guard let user = user else { return }
        
        let logReference = realtimeReference.reference().child("log").childByAutoId()
        guard let logName = logReference.key else { return }
        
        let values: [String: Any] = [
            "date": dateFormatter.string(from: Date()),
            "distance": movedDistance,
            "nick": user.nickName,
            "route": fileName,
            "runner": user.UID,
            "time": timeElapsed,
        ]
        
        logReference.setValue(values)
        print("[Success] registerNewLog")
        
        uploadLogImage(with: screenshotImage, named: logName)
    }
    
    func finishRunning() {
        print("운동을 종료합니다")
        startedRunning = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        hapticfeedbackGenerator.notificationOccurred(.success)
        
        let track = GPXTrack()                          // inits a track
        let tracksegment = GPXTrackSegment()            // inits a tracksegment
        tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
        track.add(trackSegment: tracksegment)           // adds a track segment to a track
        root.add(track: track)                          // adds a track
        root = GPXRoot(creator: "Pace Maker")

        uploadGPX()
        performSegue(withIdentifier: "Result", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? RunningResultViewController {
            nextVC.distance = movedDistance
            nextVC.routeImage = mapView.takeScreenshot()
            nextVC.time = timeElapsed
        }
    }
    
    @objc func handleTimerEvent()
    {
        if isRunning {
            timeElapsed += 1
        }
        updateUI()
    }
    
    func updateUI() {
        elapsedTimeLabel.text = "\(timeElapsed)"
        movedDistanceLabel.text = "\(String(format:"%.2f",movedDistance))"
        if movedDistance != 0 {
            let paceInSeconds: Int = Int(Double(timeElapsed) / movedDistance)
            
            currentPaceLabel.text = "\(paceInSeconds/60) :\(paceInSeconds % 60)"
        }else {
            currentPaceLabel.text = "- : --"
        }

    }
    
    func setNavigationBar() {
        self.navigationController?.navigationItem.leftBarButtonItem = nil
    }

    @IBAction func tappedPlayPause(_ sender: Any) {
        print("tapped")
        isRunning = !isRunning
        if isRunning {
            // 원래는 = 였다가 이제 play
            startPauseImage.image = UIImage(systemName: "pause")
            if !startedRunning{
                startRunning()
            }else {
                resumeRunning()
            }
        }else {
            // 원래는 playing
            startPauseImage.image = UIImage(systemName: "play")
            stopRunning()
        }
    }
}

// LOCATION 관련
extension RunningViewController :CLLocationManagerDelegate{
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // This level of accurate is available only if isAuthorizedForPreciseLocation is true.
        locationManager.distanceFilter = .zero
        
        // 백그라운드 설정
        locationManager.allowsBackgroundLocationUpdates = true
        
        alert.addAction(UIAlertAction(title: "권한요청", style: .default, handler: { UIAlertAction in
            self.checkLocationAuthrization()
        }))
        alert.addAction(UIAlertAction(title: "홈으로 돌아가기", style: .cancel, handler: { UIAlertAction in
            self.handleLocationUsageDisabled()
        }))
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    /// 앱별로 위치정보 사용동의 값이 다를 수 있는데, 확인하고 각자 필요한 후처리를 해주는 함수.
    //    @available(iOS 14.0, *)
    func checkLocationAuthrization() {
        
        print("location usage permisson - \(locationManager.authorizationStatus.rawValue)")
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse: // foreground 에서만 location 정보가 필요한 경우
                // Do Map Stuff
                startTrackingUserLocation()
                break;
            case .authorizedAlways: // background 에서 location 을 갖기 위해서는 필요하다.
                print("location usage permisson - authorizedAlways")
                break;
            case .denied:
                print("location usage permisson - denied")
                present(alert, animated: false, completion: nil) // 위치 정보 사용에 동의가 되어있지 않은경우, 기능을 사용하기위해 사람들이 해야할 동작들을 명시해주자
                break
            case .notDetermined:
                print("location usage permisson - notDetermined")
                locationManager.requestWhenInUseAuthorization()
                //                locationManager.requestAlwaysAuthorization() <<- 에러
                break
            case .restricted:
                print("location usage permisson - restricted")
                present(alert, animated: false, completion: nil)
                // show an alert
                break;
            @unknown default:
                fatalError()
        }
    }
    
    func startTrackingUserLocation(){
        centerViewOnUserLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    /// device-wide 하게 위치 정보 사용이 켜져있는지 먼저 확인한다
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthrization()
        }else{
            
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // locations 에 아무것도 반환되지 않은경우, 아무일도 하지 않는다.
        
        // GPX
        let coordinate = location.coordinate
        let trackpoint = GPXTrackPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        trackpoint.elevation = location.altitude
        trackpoint.time = Date()
        
        trackpoints.append(trackpoint)
        
        let _ = "lati : \(String(format: "%3.8f",location.coordinate.latitude))\nlong: \(String(format: "%3.8f",location.coordinate.longitude))"

        // calculated UI Labels
        let distance = location.distance(from: previousLocation!)
        movedDistance += distance / 1000 // unit transformation
        previousLocation = location
        
        //drawing path or route covered
        if let oldLocationNew = previousLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = location.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            mapView.addOverlay(polyline)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthrization()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
        
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    func handleLocationUsageDisabled(){
        
    }
}

// MAPVIEW 관련
extension RunningViewController: MKMapViewDelegate{
    func addCompetitorOverlay() {
        guard let competitorPolyline = competitorPolyline else { return }
        self.mapView.addOverlay(competitorPolyline, level: .aboveLabels)
    }
}

// GPX 관련
extension RunningViewController {
    func uploadGPX(){
        guard let _ = user else { return }
        
        // filepath to upload
        let gpxFormatSuffix: String = ".gpx"
        let fileName = String(gpxFileNameFormat.string(from: Date())) + gpxFormatSuffix
        let filePath = "routes/" + fileName
        
        // metadata
        let metaData = StorageMetadata()
        metaData.contentType = "xml"
        
        // encdoing using utf-8
        let data: Data? = root.gpx().data(using: .utf8)
        guard let dataToPut = data else {return}
        storage.reference().child(filePath).putData(dataToPut,metadata: metaData){
            (metaData,error) in if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("[Success] uploadGPX")
                banner1.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self)
                self.uploadLog(with: fileName)
            }
        }
        
    }
}

extension RunningViewController : NotificationBannerDelegate {
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner) {
        
    }

    func notificationBannerDidAppear(_ banner: BaseNotificationBanner) {
        
    }

    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner) {
        
    }

    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner) {
        
    }
}
