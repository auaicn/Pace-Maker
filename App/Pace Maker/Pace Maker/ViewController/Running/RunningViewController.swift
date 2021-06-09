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

class RunningViewController: UIViewController{
    
    var competitorLog: Log? = nil
    var movedDistance: Double = 0
    var timeElapsed: Int = 0
    var isRunning: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    
//    @IBOutlet weak var coordinateLabel: UILabel!
//    @IBOutlet weak var altitudeLabel: UILabel!
//    @IBOutlet weak var timeStampLabel: UILabel!
//    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var movedDistanceLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var startPauseImage: UIImageView!
    
    var isVoiceFeedbackEnabled: Bool = false
    var isVoiceRecordingEnabled: Bool = false
    var isAutoStopEnabled: Bool = false
    var isTrackingStarted: Bool = false
    
    var previousLocation :CLLocation?
    var locationManager : CLLocationManager = CLLocationManager()
    let regionMeters: Double = 1000
    let format = DateFormatter()
    let fileNameFormat = DateFormatter()
    
    let alert = UIAlertController(title: "권한 오류", message: "위치 정보 사용이 필요합니다.", preferredStyle: .alert)
    
    var root = GPXRoot(creator: "Pace Maker") // insert your app name here
    var trackpoints = [GPXTrackPoint]()
    
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        setNavigationBar()
        setRunningStopGesture()
        checkLocationServices()
        format.dateFormat = "MM / dd HH : mm : ss"
        fileNameFormat.dateFormat = "MMdd-HHmmssHH"
        
    }
    
    @IBAction func longPressedMapView(_ sender: Any) {
        let alert = UIAlertController(title: "권한 오류", message: "위치 정보 사용이 필요합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "롱프레스", style: .cancel, handler: nil))
    }
    
    func startRunning() {
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(secondElapsed), userInfo: nil, repeats: true)
    }
    
    @objc func secondElapsed()
    {
        if isRunning {
            timeElapsed += 1
        }
        updateUI()
    }
    
    func updateUI() {
        elapsedTimeLabel.text = "\(timeElapsed)"
        movedDistanceLabel.text = "\(movedDistance)"
    }
    
    func setRunningStopGesture() {
        longPressGesture.numberOfTapsRequired = 2
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        self.navigationController?.title = "Beat \(competitorLog?.nickname ?? "Myself") 🔥"
        
    }
    
    var touched : Bool = false;
    @IBAction func buttonTouched(_ sender: Any) {
        touched = !touched
        if touched == true {
            button.setTitle("중지", for: .normal)
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }else {
            button.setTitle("시작", for: .normal)
            locationManager.stopUpdatingHeading()
            locationManager.stopUpdatingLocation()
            
            // 달리기 완료
            let track = GPXTrack()                          // inits a track
            let tracksegment = GPXTrackSegment()            // inits a tracksegment
            tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
            track.add(trackSegment: tracksegment)           // adds a track segment to a track
            root.add(track: track)                          // adds a track
            root = GPXRoot(creator: "Pace Maker")

            uploadGPX(with: "routes/")
        }
    }
    @IBOutlet weak var button: UIButton!
    
    @IBAction func tappedPlayPauseButton(_ sender: UIButton) {
        startRunning()
        isRunning = !isRunning
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            startPauseImage.image = UIImage(systemName: "pause")
            view.backgroundColor = UIColor(named: "AccentColor")
        }else {
            startPauseImage.image = UIImage(systemName: "play")
            view.backgroundColor = .systemBackground
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
    
    func handleLocationDisabled() {
        
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
        
        let coordinate = location.coordinate
        let trackpoint = GPXTrackPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        trackpoint.elevation = location.altitude
        trackpoint.time = Date()
        
        trackpoints.append(trackpoint)
        
        // 10초마다 였으면 조헥ㅆ다
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)
        let _ = "lati : \(String(format: "%3.8f",location.coordinate.latitude))\nlong: \(String(format: "%3.8f",location.coordinate.longitude))"

        // UI labels
//        coordinateLabel.text = locationDescription
//        altitudeLabel.text = String(format: "%3.8f",location.altitude)
//        speedLabel.text = String(location.speed)
//        timeStampLabel.text = String(format.string(from: location.timestamp))

        // calculated UI Labels
        let distance = location.distance(from: previousLocation!)
//        print("distance", distance)
//        print("distance", String(distance))
        movedDistanceLabel.text = String(distance)

        previousLocation = location
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
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let center = getCenterLocation(for: mapView)
//        let geoCoder = CLGeocoder()
//
//        guard center.distance(from: previousLocation!) > 50 else {return}
//        previousLocation = center
//
//        geoCoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
//            guard let self = self else {return}
//
//            if let _ = error {
//                return
//            }
//
//            guard let placemark = placemarks?.first else{
//                return
//            }
//
//            let streetNumber = placemark.subThoroughfare
//
//        }
//    }
    
    
    func addCompetitorOverlay() {
        guard let competitorPolyline = competitorPolyline else { return }
        self.mapView.addOverlay(competitorPolyline, level: .aboveLabels)
    }
    
}

// GPX 관련
extension RunningViewController {
    
    func finishRunning() {
//        result view 띄워준다. 현재 뛴 정보로
        
//        uploadGPX 를 하는데 로그인이 안되어 있으면..?
        
    }
    
    func uploadGPX(with prefix: String){
        // filepath to upload
        let gpxFormatSuffix :String = ".gpx"
        let fileName = String(fileNameFormat.string(from: Date()))
        let filePath = prefix + fileName + gpxFormatSuffix
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
                print("성공")
            }
        }
        
    }
}
