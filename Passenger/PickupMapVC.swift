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
    
    var action:String=""
    
    var yourPassenger:Bool?
    var passengerID:Int?
    
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
//        print("Your passenger? ",yourPassenger!)
        
        nameLabel.text = name!
        phoneLabel.text = phoneNumber!
        
//        print("Latitude: \(lat!), Longitude: \(long!)")
        
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
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        let pickupAnnotation = PickupAnnotation(coordinate: pickupCoordinates!, title: "\(name!)", subtitle: "Pickup Here!")
        mapView.addAnnotation(pickupAnnotation)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pickupCoordinates!, span)
        mapView.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmPushed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Pickup Confirm", message: "Are you sure you want to mark this person as picked up?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.action="pickup"
            self.pickupComplete()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        DispatchQueue.main.async{
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Cancel Confirm", message: "Are you sure you want to cancel your pickup of this person?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.action="cancel"
            self.removeDriver()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        DispatchQueue.main.async{
            self.present(alert, animated: true)
        }
    }
    @IBAction func removePushed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Remove Confirm", message: "Are you sure you want to remove this person from the queue?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.action="remove"
            self.removePassenger()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        DispatchQueue.main.async{
            self.present(alert, animated: true)
        }
    }
    func removeDriver(){
        let urlReq: URL = URL(string: "\(SERVER.IP)/removePassengerDriver/")!
        var request = URLRequest(url:urlReq)
        request.httpMethod = "POST"
        let bodyData = "passengerID=\(passengerID!)"
        request.httpBody=bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data, response, error in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                    let response = jsonResult["response"] as! String
                    if response == "success"{
                        let alert = UIAlertController(title: "Cancel Success", message: "Successfully removed yourself as this persons driver", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                            self.performSegue(withIdentifier: "unwindFromMapVC", sender: "cancel")
                        }
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        let alert = UIAlertController(title: "Cancel Fail", message: "Unable to remove yourself as this person's driver", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    func removePassenger(){
        let urlReq: URL = URL(string: "\(SERVER.IP)/removeFromQueue/")!
        var request = URLRequest(url:urlReq)
        request.httpMethod = "POST"
        let bodyData = "userID=\(passengerID!)"
        request.httpBody=bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data, response, error in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                    let response = jsonResult["response"] as! String
                    if response=="success"{
                        let alert = UIAlertController(title: "Remove Succes", message: "Successfully removed this passenger from the queue.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                            self.performSegue(withIdentifier: "unwindFromMapVC", sender: "remove")
                        }
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    func pickupComplete(){
        let urlReq: URL = URL(string: "\(SERVER.IP)/removeFromQueue/")!
        var request = URLRequest(url:urlReq)
        request.httpMethod = "POST"
        let bodyData = "userID=\(passengerID!)"
        request.httpBody=bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data, response, error in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                    let response = jsonResult["response"] as! String
                    if response=="success"{
                        let alert = UIAlertController(title: "Pickup Success", message: "Successfully picked up this passenger!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                            self.performSegue(withIdentifier: "unwindFromMapVC", sender: "pickup")
                        }
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
}
extension PickupMapVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let showDirections = yourPassenger as? Bool{
            if showDirections == true{
                let location = locations[0]
                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pickupAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView{
            pickupAnnotationView.animatesWhenAdded = true
            pickupAnnotationView.titleVisibility = .adaptive
            pickupAnnotationView.subtitleVisibility = .adaptive
            
            return pickupAnnotationView
        }
        return nil
    }
}

class PickupAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title:String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title:String, subtitle:String){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}
