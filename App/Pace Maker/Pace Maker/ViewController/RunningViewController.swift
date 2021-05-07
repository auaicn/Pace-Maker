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

    // Core GPX
    let root = GPXRoot(creator: APP_NAME) // insert your app name here
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // This level of accurate is available only if isAuthorizedForPreciseLocation is true.
        locationManager.distanceFilter = .zero
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }else {
            print("locationManager's location not loaded")
        }
    }
    
    let alert = UIAlertController(title: "No Permission", message: "Geo Location Usages is denied", preferredStyle: .alert)
    
    /// 앱별로 위치정보 사용동의 값이 다를 수 있는데, 확인하고 각자 필요한 후처리를 해주는 함수.
    func checkLocationAuthrization() {
        print("Checking Location Usage Permission")
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
    
    /// start updating user location & device dependent heading
    /// startUpdatingLocation 는 내부적으로 locationManagerdidUpdateHeading 를 부릅니다.
    func startTrackingUserLocation(){
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable(){
            locationManager.startUpdatingHeading()  // device dependent
        }
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
    }
    
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    let locationLoadedForFirstTime:Bool = false
}

extension RunningViewController :CLLocationManagerDelegate{

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if previousLocation == nil {
            previousLocation = location
            centerViewOnUserLocation()
            updateLocationLookup(with: location)
        }
        
        let timeElapsedFromLastUpdate = location.timestamp.timeIntervalSince(previousLocation!.timestamp)
        if timeElapsedFromLastUpdate < MINUMUM_UPDATE_PERIOD { return }
        print("location updated. elasped time",timeElapsedFromLastUpdate)
        
        // Update UI Labels
        updateLocationLookup(with: location)
        
        // Core GPX
        var trackpoints = [GPXTrackPoint]()
        
        let yourLatitudeHere: CLLocationDegrees = 1.3521
        let yourLongitudeHere: CLLocationDegrees = 103.8198
        let yourElevationValue: Double = 10.724
        
        let trackpoint = GPXTrackPoint(latitude: yourLatitudeHere, longitude: yourLongitudeHere)
        trackpoint.elevation = yourElevationValue
        trackpoint.time = Date() // set time to current date
        trackpoints.append(trackpoint)
        
        let track = GPXTrack()                          // inits a track
        let tracksegment = GPXTrackSegment()            // inits a tracksegment
        tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
        track.add(trackSegment: tracksegment)           // adds a track segment to a track
        root.add(track: track)                          // adds a track
        
//        print(root.gpx())
        

        previousLocation = location
    }
    
    func updateLocationLookup(with location:CLLocation) -> Void {
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
        courseAccuracyLabel.text = String(location.courseAccuracy)
        timeStampLabel.text = String(format.string(from: location.timestamp))
        // calculated UI Labels
        let distance = location.distance(from: previousLocation!)
        movedDistanceLabel.text = String(distance)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to retrieve location")
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
            
//            let streetNumber = placemark.subThoroughfare
//            let streetNumber = placemark.subThoroughfare
            self.currentLocationLabel.text = placemark.name
            
        }
//        geoCoder.reverseGeocodeLocation(center, completionHandler: g)
        
    }
}
