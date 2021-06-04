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

class RouteDetailViewController: UIViewController {
    
    var rootGPX: GPXRoot? = nil
    var route: Route? = nil
    let sourceLocation = CLLocationCoordinate2D(latitude: 37.518207217837876, longitude:127.01001167904042)
    let destinationLocation = CLLocationCoordinate2D(latitude: 37.53393643481008, longitude: 127.02611500393752)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        downloadGPX()
    }
    
    func downloadGPX(){
        guard let selectedRoute = route else { return }
        let fileName = selectedRoute.routeSavedPath
        let filePath = fileName + ".gpx"
//        let filePath = "0526-01435801.gpx"
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
            guard let latitude = trackPoint.latitude else { return false }
            guard let longitude = trackPoint.longitude else { return false }
            return true
        }.map { trackPoint in
            return CLLocationCoordinate2D(latitude: trackPoint.latitude!, longitude: trackPoint.longitude!)
        }
        // these are your two lat/long coordinates
//        CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(lat1,long1);
//        CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(lat2,long2);
//        
//        // convert them to MKMapPoint
//        MKMapPoint p1 = MKMapPointForCoordinate (coordinate1);
//        MKMapPoint p2 = MKMapPointForCoordinate (coordinate2);
//        
//        // and make a MKMapRect using mins and spans
//        MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
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
            
            let polyline = MKPolyline(coordinates: pointer, count: count)
            self.mapView.addOverlay(polyline, level: .aboveLabels)
            
            
            var rect = polyline.boundingMapRect
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKPolyline {
            /// define a list of colors you want in your gradient
//            let gradientColors = [UIColor.green, UIColor.blue, UIColor.yellow, UIColor.red]
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
