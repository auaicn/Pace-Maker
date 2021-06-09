//
//  RouteDetailViewController.swift
//  Pods
//
//  Created by Kyungho on 2021/05/28.
//

import UIKit
import MapKit
import CoreGPX
import FirebaseStorage
import CoreLocation

var competitorPolyline: MKPolyline? = nil

class RouteDetailViewController: UIViewController {
    
    let MAP_VIEW_SCALE_FACTOR: Double = 1.3
    
    var rootGPX: GPXRoot? = nil
    var log: Log? = nil
    
    @IBOutlet weak var RouteTitle: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var isVoiceFeedbackEnabled: UISwitch!
    @IBOutlet weak var isVoiceRecordingEnabled: UISwitch!
    @IBOutlet weak var isAutoStopEnabled: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadGPX()
        setMapView()
        updateUI()
    }
    
    func updateUI(){
        updateSettingUI()
        updateDetailedRouteUI()
    }
    
    func updateSettingUI(){
        if authenticationStatus == .notLoggined {
            isVoiceFeedbackEnabled.isEnabled = false
        }
        isVoiceRecordingEnabled.isOn = true
        isAutoStopEnabled.isOn = true
    }

    
    func updateDetailedRouteUI(){
        guard let log = log else { return }

        RouteTitle.text = "\(log.nickname) 님의 달리기"
        paceLabel.text = "페이스: 1 km 당 \(log.paceString)"
        distanceLabel.text = "거리: \(String(format: "%.2f", log.distanceInKilometer)) km"
        let (hour, minute, second): (Int, Int, Int) = log.timeDescription
        if hour != 0 {
            timeLabel.text = "시간: \(hour) 시간 \(minute) 분 \(second) 초"
        }else if minute != 0 {
            timeLabel.text = "시간: \(minute) 분 \(second) 초"
        }else{
            timeLabel.text = "시간: \(second) 초"
        }
        paceLabel.text = "\(log.paceDescription) PER 1 KM"
    }

    
    func downloadGPX(){
        guard let selectedRoute = log else { return }
        let fileName = selectedRoute.routeSavedPath
        let filePath = fileName + ".gpx"
        
        storage.reference(forURL: "gs://pace-maker-74452.appspot.com/routes").child(filePath).downloadURL { (url, error) in
            guard let url = url else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.rootGPX = GPXParser(withURL: url)?.parsedData()
            self.createPath()
        }
    }
    
    func createPath() {
        guard let rootGPX = self.rootGPX else { return }
        
        let trackPoints = rootGPX.tracks[0].segments[0].points
        let coords: [CLLocationCoordinate2D] = trackPoints.filter { trackPoint in
            guard let _ = trackPoint.latitude else { return false }
            guard let _ = trackPoint.longitude else { return false }
            return true
        }.map { trackPoint in
            return CLLocationCoordinate2D(latitude: trackPoint.latitude!, longitude: trackPoint.longitude!)
        }
        
        do {
            print("Typed pointers")
            let count = coords.count
            let pointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
            pointer.initialize(repeating: coords[0], count: count)
            defer {
                pointer.deinitialize(count: count)
                pointer.deallocate()
            }
            
            for i in 1..<count {
                pointer.advanced(by: i).pointee = coords[i]
            }
            
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: count)
            for (index, value) in bufferPointer.enumerated() {
                print("value \(index): \(value)")
            }
            
            competitorPolyline = MKPolyline(coordinates: pointer, count: count)
            
            guard let competitorPolyline = competitorPolyline else { return }
            
            self.mapView.addOverlay(competitorPolyline, level: .aboveLabels)
            
            var rect = competitorPolyline.boundingMapRect
            print(rect)
            print(rect.size.width)
            print(rect.size.height)
            rect.size = MKMapSize(width: rect.size.width * 2, height: rect.size.height * 2)
            print(rect)
            print(rect.size.width)
            print(rect.size.height)
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    
    func createPath(with sourceLocation:CLLocationCoordinate2D,and destinationLocation:CLLocationCoordinate2D){
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemakr = MKPlacemark(coordinate: destinationLocation)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemakr)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "start"
        sourceAnnotation.subtitle = "sub title of start"
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "destination"
        destinationAnnotation.subtitle = "dest sub title"
        if let location = destinationPlacemakr.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate() { (response, error) in
            guard let response = response else {
                if let error  = error {
                    print("Error Found : \(error.localizedDescription)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveLabels)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }

}

extension RouteDetailViewController : MKMapViewDelegate {
    func setMapView() {
        self.mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKPolyline {
            let gradientColors = [UIColor.orange, UIColor.blue, UIColor.black, UIColor.red]
            
            /// Initialise a GradientPathRenderer with the colors
            let polylineRenderer = GradientPathRenderer(polyline: overlay, colors: gradientColors)
            
            /// set a linewidth
            polylineRenderer.lineWidth = 7
            return polylineRenderer
        } else {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 5
            renderer.strokeColor = .systemOrange
            
            return renderer
        }
    }
}
