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
    
    let manager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBAction func backPushed(_ sender: UIButton) {
//        performSegue(withIdentifier: "MapToDriveSegue", sender: "MapToDrive")
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let driverCoordinates = manager.location?.coordinate
        let pickupCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!)
        
        let sourcePlacemark = MKPlacemark(coordinate: driverCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: pickupCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error{
                    print("Something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveLabels)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension PickupMapVC:CLLocationManagerDelegate{
    
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
        renderer.lineWidth = 5.0
        return renderer
    }
}
