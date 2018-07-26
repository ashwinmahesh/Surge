//
//  DriveQueueVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class DriveQueueVC: UIViewController {
    
    var orgID:Int?
    var orgName:String?
    var hasSelectedPassenger:Bool=false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var queueNameLabel: UILabel!
    var tableData:[NSDictionary]=[]
    var userID:Int64 = -1

    @IBOutlet weak var tableView: UITableView!
    @IBAction func homePushed(_ sender: UIButton) {
        performSegue(withIdentifier: "DriveToHomeSegue", sender: "DriveToHome")
    }
    
    @IBAction func adminPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "DriverToAdminSegue", sender: "DriverToAdmin")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=120
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        
        do{
            let user = try context.fetch(fetchRequest).first!
            userID = user.id
        }
        catch{
            print("There was an error")
        }

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchQueue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromMapVC(segue: UIStoryboardSegue){
        if segue.identifier == "unwindFromMapVC"{
            let source = segue.source as! PickupMapVC
            print("Source action: \(source.action)")
            if source.action=="cancel"{
                hasSelectedPassenger = false
            }
            else if source.action=="remove"{
                hasSelectedPassenger = false
            }
            else if source.action=="pickup"{
                hasSelectedPassenger = false
            }
        }
    }
    
    func fetchQueue(){
        tableData=[]
        let urlReq=URL(string: "\(SERVER.IP)/fetchQueue/")!
        var request = URLRequest(url:urlReq)
        request.httpMethod = "POST"
        let bodyData = "orgID=\(orgID!)"
        request.httpBody = bodyData.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data,response,error in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                    print(jsonResult)
                    let response = jsonResult["response"] as! String
                    self.orgName = jsonResult["name"] as! String
                    DispatchQueue.main.async{
                        self.queueNameLabel.text = "\(self.orgName!) Queue"
                    }
                    if response=="Could not find organization"{
                        let alert = UIAlertController(title: "Error", message: "We could not fetch the queue for this organization.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            return
                        })
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        let queue = jsonResult["queue"] as! NSMutableArray
                        for user in queue{
                            let userFixed = user as! NSDictionary
                            if (userFixed["driver_id"] as! Int64)==self.userID{
                                self.hasSelectedPassenger=true
                            }
                            self.tableData.insert(userFixed, at: 0)
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="DriveQueueToMapSegue"{
            let dest = segue.destination as! PickupMapVC
            let indexPath = sender as! IndexPath
            let cell = tableView.cellForRow(at: indexPath) as! DriveQueueCell
//            print("Cell.driverID: \(cell.driverID!), userID: \(userID)")
            if cell.driverID! == userID{
                dest.yourPassenger = true
            }
            else{
                dest.yourPassenger = false
            }
            let user = tableData[indexPath.row]
            dest.name = (user["first_name"] as! String) + " " + (user["last_name"] as! String)
            dest.phoneNumber = user["phone_number"] as! String
            dest.passengerID = cell.userID
            dest.lat = Double(user["lat"] as! String)
            dest.long = Double(user["long"] as! String)
        }

    }
    
    
}
extension DriveQueueVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath) as! DriveQueueCell
        let currentUser=tableData[indexPath.row]
        
        cell.nameLabel.text = (currentUser["first_name"] as! String) + " " + (currentUser["last_name"] as! String)
        
        if (currentUser["driver_id"] as! Int) == -1{
            cell.statusLabel.text = "Driver: Not Assigned"
            if hasSelectedPassenger{
                cell.pickupButton.isHidden=true
            }
            else{
                cell.pickupButton.isHidden=false
            }
        }
        else{
            cell.statusLabel.text = "Driver: \(currentUser["driver"] as! String)"
            cell.pickupButton.isHidden=true
//            cell.statusLabel.text = "Driver: Assigned"
        }
        print("hasSelectedPassenger: ", hasSelectedPassenger)

        if hasSelectedPassenger && (currentUser["driver_id"] as! Int64)==userID{
            cell.pickupButton.isHidden=false
            cell.pickupButton.backgroundColor = UIColor.orange
            cell.pickupButton.setTitle("Yours", for: .normal)
            cell.pickupButton.isEnabled=false
        }
        else{
            cell.pickupButton.backgroundColor = UIColor.init(red: CGFloat(114.0/255.0), green: CGFloat(136.0/255.0), blue: CGFloat(247.0/255.0), alpha: CGFloat(1.0))
            cell.pickupButton.setTitle("Pickup", for: .normal)
            cell.pickupButton.isEnabled=true
        }
        
        cell.phoneNumber = currentUser["phone_raw"] as! String
        cell.addressLabel.text = currentUser["location"] as! String
        cell.userID = currentUser["id"] as! Int
        cell.delegate=self
        cell.driverID = currentUser["driver_id"] as! Int64
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "DriveQueueToMapSegue", sender: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let call = UIContextualAction(style: .normal, title: "Call") { (action, view, finishAnimation) in
            self.placeCall(cell: tableView.cellForRow(at: indexPath) as! DriveQueueCell)
            finishAnimation(true)
        }
        call.backgroundColor = UIColor.init(red: CGFloat(79.0/255.0), green: CGFloat(143.0/255.0), blue: 0, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [call])
        return swipeConfig
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pickup = UIContextualAction(style: .normal, title: "Pickup") { (action, view, finishAnimation) in
            if self.hasSelectedPassenger == false{
                self.pickupPushed(cell: tableView.cellForRow(at: indexPath) as! DriveQueueCell)
            }
            else{
                let alert = UIAlertController(title: "Pickup Conflict", message: "You are already assigned to pick someone else up! Finish this ride first before you move on to the next one.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default){
                    action in
                    return
                }
                alert.addAction(ok)
                DispatchQueue.main.async{
                    self.present(alert, animated: true)
                }
            }
            finishAnimation(true)
        }
        pickup.backgroundColor = UIColor.init(red: 114.0/255.0, green: 136.0/255.0, blue: 247.0/255.0, alpha: 1)
        
        let swipeConfig = UISwipeActionsConfiguration(actions:[pickup])
        return swipeConfig
    }
}

extension DriveQueueVC:DriveQueueCellDelegate{
    func placeCall(cell: DriveQueueCell){
        let phoneNumber = cell.phoneNumber!
        let url:URL = URL(string: "telprompt://\(phoneNumber)")!
        UIApplication.shared.open(url)
    }
    
//    override var prefersStatusBarHidden: Bool{
//        return true
//    }
    
    func pickupPushed(cell: DriveQueueCell) {
        let pickupAlert = UIAlertController(title: "Pickup Confirm", message: "Are you sure you want to pick this person up?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.hasSelectedPassenger=true
            self.pickupPerson(cell: cell)
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        pickupAlert.addAction(yes)
        pickupAlert.addAction(no)
        DispatchQueue.main.async{
            self.present(pickupAlert, animated: true)
        }
    }
    
    func pickupPerson(cell:DriveQueueCell){
        let indexPath = tableView.indexPath(for: cell)!
        
        let urlReq: URL = URL(string: "\(SERVER.IP)/assignPassengerDriver/")!
        var request = URLRequest(url:urlReq)
        request.httpMethod = "POST"
        let bodyData = "passengerID=\(cell.userID!)&driverID=\(userID)"
        request.httpBody=bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data, response, error in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                    let response = jsonResult["response"] as! String
                    if response=="Unable to pick this person up"{
                        let alert = UIAlertController(title: "Pickup Error", message: "We are unable to assign you to this passenger", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated:true)
                        }
                        return
                    }
                    else{
                        let alert = UIAlertController(title: "Pickup Success", message: "You are now assigned to pick this person up. Give them a call to let them know you are on the way!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: {action in
                            let indexPath = self.tableView.indexPath(for: cell)
                            cell.driverID=self.userID
                            DispatchQueue.main.async{
                                self.performSegue(withIdentifier: "DriveQueueToMapSegue", sender: indexPath)
                            }
                        })
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated:true)
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
