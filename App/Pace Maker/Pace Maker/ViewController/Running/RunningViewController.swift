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
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var movedDistanceLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var horizontalAccuracyLabel: UILabel!
    @IBOutlet weak var speedAccuracyLabel: UILabel!
    @IBOutlet weak var courseAccuracyLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    var previousLocation :CLLocation?
    var locationManager : CLLocationManager = CLLocationManager()
    var isTrackingStarted: Bool = false
    let regionMeters: Double = 1000
    let format = DateFormatter()
    let fileNameFormat = DateFormatter()
    
    var root = GPXRoot(creator: "Pace Maker") // insert your app name here
    var trackpoints = [GPXTrackPoint]()
    
    let storage = Storage.storage()
    
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
            
            let track = GPXTrack()                          // inits a track
            let tracksegment = GPXTrackSegment()            // inits a tracksegment
            tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
            track.add(trackSegment: tracksegment)           // adds a track segment to a track
            root.add(track: track)                          // adds a track
            
            uploadGPX(with: "routes/")
            
            root = GPXRoot(creator: "Pace Maker")
        }
    }
    @IBOutlet weak var button: UIButton!
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // This level of accurate is available only if isAuthorizedForPreciseLocation is true.
        locationManager.distanceFilter = .zero
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    let alert = UIAlertController(title: "No Permission", message: "Geo Location Usages is denied", preferredStyle: .alert)
    
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
                present(alert,animated: false,completion: nil) // 위치 정보 사용에 동의가 되어있지 않은경우, 기능을 사용하기위해 사람들이 해야할 동작들을 명시해주자
                break
            case .notDetermined:
                print("location usage permisson - notDetermined")
                locationManager.requestWhenInUseAuthorization()
//                locationManager.requestAlwaysAuthorization() <<- 에러
                break
            case .restricted:
                print("location usage permisson - restricted")
                present(alert,animated: false,completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = false
        checkLocationServices()
        format.dateFormat = "MM / dd HH : mm : ss"
        fileNameFormat.dateFormat = "MMdd-HHmmssHH"
    }
    
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension RunningViewController :CLLocationManagerDelegate{
    
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
        let locationDescription = "lati : \(String(format: "%3.8f",location.coordinate.latitude))\nlong: \(String(format: "%3.8f",location.coordinate.longitude))"

        // UI labels
        coordinateLabel.text = locationDescription
        altitudeLabel.text = String(format: "%3.8f",location.altitude)
        speedLabel.text = String(location.speed)
        floorLabel.text = String(location.floor?.level ?? -4)
        horizontalAccuracyLabel.text = String(location.horizontalAccuracy)
        speedAccuracyLabel.text = String(location.speedAccuracy)
        courseAccuracyLabel.text = String(location.courseAccuracy) // 필요없는.. 것 같은데
        timeStampLabel.text = String(format.string(from: location.timestamp))

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
}

extension RunningViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard center.distance(from: previousLocation!) > 50 else {return}
        previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
            guard let self = self else {return}
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else{
                return
            }
            
            let streetNumber = placemark.subThoroughfare
            
        }
        
    }
}
