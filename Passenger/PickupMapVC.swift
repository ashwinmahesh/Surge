//
//  PickupMapVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PickupMapVC: UIViewController {
    var name:String?
    var phoneNumber:String?
    var lat:Double?
    var long:Double?
    
    var yourPassenger:Bool?
    
    @IBOutlet var statusButtons: [UIButton]!
    let manager = CLLocationManager()
    var pickupCoordinates:CLLocationCoordinate2D?
    var destPlacemark:MKPlacemark?
    var destItem:MKMapItem?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBAction func backPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Your passenger? ",yourPassenger!)
        
        nameLabel.text = name!
        phoneLabel.text = phoneNumber!
        
        print("Latitude: \(lat!), Longitude: \(long!)")
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
//        placeDest()
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        pickupCoordinates = CLLocationCoordinate2DMake(lat!, long!)
        destPlacemark = MKPlacemark(coordinate: pickupCoordinates!)
        destItem = MKMapItem(placemark: destPlacemark!)
        
        if let showButtons = yourPassenger as? Bool{
            if showButtons == false{
                for button in statusButtons{
                    button.isHidden=true
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension PickupMapVC:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.005, 0.005)
        let sourceLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(sourceLocation, span)
        let driverCoordinates = manager.location?.coordinate
        let sourcePlacemark = MKPlacemark(coordinate: driverCoordinates!)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else{
                if let error = error{
                    print("Something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveLabels)
            self.mapView.setRegion(region, animated: true)
            
        }
    }
    
    func placeDest(){
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let pickupLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!)
        let region = MKCoordinateRegionMake(pickupLocation, span)
        mapView.setRegion(region, animated: true)
        //Place annotation here
    }
}

extension PickupMapVC:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 6.0
        return renderer
    }
}
