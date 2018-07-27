//
//  OrganizationVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class OrganizationVC: UIViewController {
    var orgID:Int?
    
    let manager = CLLocationManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tableData:[NSDictionary]=[]
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var myLong:Double?
    var myLat:Double?
    var address:String?

    @IBOutlet weak var tableView: UITableView!
    @IBAction func backPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func requestRidePushed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Join Queue", message: "Are you sure you want to join this queue? You will lose your place in any other queue you are in.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.joinQueue()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler:nil)
        alert.addAction(yes)
        alert.addAction(no)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    func joinQueue(){
        var id:Int64?
        let request:NSFetchRequest<User>=User.fetchRequest()
        do{
            let user = try context.fetch(request).first!
            id = user.id
        }
        catch{
            print(error)
        }
        if let urlReq = URL(string: "\(SERVER.IP)/joinQueue/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "orgID=\(orgID!)&userID=\(id!)&long=\(myLong!)&lat=\(myLat!)&address=\(address!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        let response = jsonResult["response"] as! String
                        if response=="bad"{
                            let badAlert = UIAlertController(title: "Queue Join Failure", message: "We were unable to add you to the queue for this organization. Try again later.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                                return
                            })
                            badAlert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(badAlert, animated: true)
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                self.performSegue(withIdentifier: "RequestToConfirmSegue", sender: "RequestToConfirm")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sentMessage = sender as? String{
            if sentMessage=="RequestToConfirm"{
                let dest = segue.destination as! ClientQueueVC
                dest.orgID = orgID
                dest.fromRequest=true
            }
        }
    }
    
    @IBAction func unwindFromQueue(segue:UIStoryboardSegue){
        DispatchQueue.main.async{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=90
        manager.delegate=self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
//        print("Org id: \(orgID!)")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchOrgDrivers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchOrgDrivers(){
        tableData=[]
        if let urlReq = URL(string: "\(SERVER.IP)/getOrgDrivers/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "orgID=\(orgID!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! NSDictionary
                        let users = response["users"] as! NSMutableArray
                        DispatchQueue.main.async{
                            self.nameLabel.text = jsonResult["organization"] as! String
                        }
                        for user in users{
                            let userFixed = user as! NSDictionary
                            self.tableData.append(userFixed)
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
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
}

extension OrganizationVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as! DriverCell
        let currentDriver=tableData[indexPath.row]
        cell.nameLabel.text=(currentDriver["first_name"] as! String) + " " + (currentDriver["last_name"] as! String)
        cell.phoneLabel.text = currentDriver["phone_number"] as! String
        cell.phoneNumber = currentDriver["phone_raw"] as! String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let call = UIContextualAction(style: .normal, title: "Call") { (action, view, finishAnimation) in
            self.placeCall(cell: tableView.cellForRow(at: indexPath) as! DriverCell)
            finishAnimation(true)
        }
        call.backgroundColor = UIColor.init(red: CGFloat(79.0/255.0), green: CGFloat(143.0/255.0), blue: 0, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [call])
        return swipeConfig
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeConfig = UISwipeActionsConfiguration(actions: [])
        return swipeConfig
    }
    
    func placeCall(cell:DriverCell){
        let phoneNumber = cell.phoneNumber!
        let url = URL(string: "telprompt://\(phoneNumber)")!
        UIApplication.shared.open(url)
    }
}

extension OrganizationVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        myLat = location.coordinate.latitude
        myLong = location.coordinate.longitude
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        CLGeocoder().reverseGeocodeLocation(location){ placemark, error in
            if error != nil{
                print("There was an error")
            }
            else{
                if let place = placemark?[0]{
                    self.address = "\(place.subThoroughfare!) \(place.thoroughfare!), \(place.locality!), \(place.administrativeArea!) \(place.postalCode!)"
                }
            }
        }
    }
}
