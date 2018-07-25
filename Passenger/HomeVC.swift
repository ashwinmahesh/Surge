//
//  HomeVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController {
    var drivingForId:Int?
    
    @IBOutlet weak var searchField: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var queueStatus:String=""
    var tableData:[NSDictionary]=[]
    @IBOutlet weak var tableView: UITableView!
    @IBAction func logoutPushed(_ sender: UIButton) {
        let request:NSFetchRequest<User> = User.fetchRequest()
        do{
            let result = try context.fetch(request).first
            if let user = result as? User{
                context.delete(user)
                appDelegate.saveContext()
            }
        }
        catch{
            print(error)
        }
        performSegue(withIdentifier: "HomeToLoginSegue", sender: "HomeToLogin")
    }
    @IBAction func drivePushed(_ sender: UIButton) {
        getDrivingForID()
    }
    @IBAction func adminPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeToAdminSegue", sender: "HomeToAdmin")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=115
//        fetchAllActive()
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchAllActive()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orgID = sender as? Int{
            if segue.identifier == "AllToOneOrgSegue"{
                let dest = segue.destination as! OrganizationVC
                dest.orgID=orgID
            }
            else if segue.identifier == "HomeToClientQueueSegue"{
                let dest = segue.destination as! ClientQueueVC
                dest.orgID=orgID
            }
            else if segue.identifier=="HomeToDriveSegue"{
                let dest = segue.destination as! DriveQueueVC
                dest.orgID=orgID
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchAllActive(){
        tableData=[]
        if let url = URL(string: "\(SERVER.IP)/fetchAllActive/"){
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! NSDictionary
                        let organizations = response["organizations"] as! NSMutableArray
                        for organization in organizations{
                            let organizationFixed = organization as! NSDictionary
                            self.tableData.append(organizationFixed)
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
    
    @IBAction func searchFor(_ sender: UIButton) {
        tableData=[]
        print("Entering function")
        let searchKey=searchField.text!
        if let urlReq = URL(string: "\(SERVER.IP)/searchFor/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod = "POST"
            let bodyData="key=\(searchKey)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest){
                data, response, error in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! NSDictionary
                        let organizations = response["organizations"] as! NSMutableArray
                        for organization in organizations{
                            let organizationFixed = organization as! NSDictionary
                            self.tableData.append(organizationFixed)
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
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationCell", for: indexPath) as! OrganizationCell
        let currentOrg=tableData[indexPath.row]
        cell.organizationLabel.text = currentOrg["name"] as! String
        cell.driverCountLabel.text = "Drivers: \(currentOrg["drivers"] as! Int)"
        cell.orgID = currentOrg["id"] as! Int
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell=tableView.cellForRow(at: indexPath) as! OrganizationCell
        getQueueStatus(cell: cell)
        
        if self.queueStatus=="not in line"{
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "AllToOneOrgSegue", sender: cell.orgID!)
            }
        }
        else if self.queueStatus=="in line"{
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "HomeToClientQueueSegue", sender: cell.orgID!)
            }
        }
//
    }
    func getQueueStatus(cell:OrganizationCell){
        var id:Int64?
        let fetchReq:NSFetchRequest<User> = User.fetchRequest()
        do{
            id = try context.fetch(fetchReq).first!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/getQueuedOrganization/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod = "POST"
            let bodyData="orgID=\(cell.orgID!)&userID=\(id!)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest){
                data, response, error in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        self.queueStatus=response
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func getDrivingForID(){
        var id:Int64?
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        do{
            id = try context.fetch(fetchRequest).first!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/getDrivingForId/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod = "POST"
            let bodyData="userID=\(id!)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest){
                data, response, error in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        if response=="success"{
                            self.drivingForId = jsonResult["drivingFor_ID"] as! Int
                            if self.drivingForId! == -1{
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "HomeToDriveNoneSegue", sender: "HomeToDriveNone")
                                }
                            }
                            else if self.drivingForId! > -1{
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "HomeToDriveSegue", sender: self.drivingForId)
                                }
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
    
}
