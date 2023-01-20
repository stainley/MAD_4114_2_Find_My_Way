//
//  ViewController.swift
//  MAD_4114_2_Find_my_way_app
//
//  Created by Stainley A Lebron R on 2023-01-17.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var transportTypeSwitch: UISwitch!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directionButton: UIButton!
    
    var locationManger = CLLocationManager()
    
    var destination: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        directionButton.isHidden = true
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        
        
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        map.delegate = self
    }
    
    @IBAction func zoomButton(_ sender: UIButton) {
        switch sender.tag {
            case 101:
                var region: MKCoordinateRegion = MKCoordinateRegion()
                var span: MKCoordinateSpan = MKCoordinateSpan()
                region.center = map.region.center
                span.latitudeDelta = map.region.span.latitudeDelta / 2.0002
                span.longitudeDelta = map.region.span.longitudeDelta / 2.0002
                region.span = span
                map.setRegion(region, animated: true)
            case 100:
                var region: MKCoordinateRegion = MKCoordinateRegion()
                var span: MKCoordinateSpan = MKCoordinateSpan()
                region.center = map.region.center
            
                span.latitudeDelta = map.region.span.latitudeDelta * 2.0002
                span.longitudeDelta = map.region.span.longitudeDelta * 2.0002
                region.span = span
                map.setRegion(region, animated: true)
            default:
                break
        }
    }
    
    @IBAction func drawRoute(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
                
        let sourcePlaceMark = MKPlacemark(coordinate: locationManger.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request direction
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)

        if transportTypeSwitch.isOn {
            directionRequest.transportType = .automobile
        } else {
            directionRequest.transportType = .walking
        }
                
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate(completionHandler: { (response, errors) -> () in
            guard let directionResponse = response else {
                return
            }
            
            let route = directionResponse.routes[0]
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        })
    }
    
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        
        
        let latDelta: CLLocationDegrees = 0.08
        let lonDelta: CLLocationDegrees = 0.08
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
        
        //let annotation = MKPointAnnotation()
        //annotation.title = title
        //annotation.subtitle = subtitle
        //annotation.coordinate = location
        //map.addAnnotation(annotation)
    }
    
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        
        annotation.title = "Final Destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionButton.isHidden = false
    }
    
    func removePin(){
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Current Location", subtitle: "")
    }
}

extension ViewController: MKMapViewDelegate {
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            return renderer
        }
        
        return MKOverlayRenderer()
    }
     
}
