//
//  AdminDriversVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class AdminDriversVC: UIViewController {
    var orgID:Int?
    var tableData:[NSDictionary]=[]
    
    @IBAction func backPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminViewToMainSegue", sender: "AdminViewToMain")
    }
    
    @IBAction func addPushed(_ sender: UIButton) {
        print("Pushing add")
        if let urlReq = URL(string: "\(SERVER.IP)/assignDriver/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "orgID=\(orgID!)&email=\(textField.text!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        if response=="User does not exist"{
                            let alert = UIAlertController(title: "Driver Add Error", message: "No user exists with that email address", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style:.default , handler: nil)
                            alert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(alert, animated:true)
                            }
                            return
                        }
                        else if response == "Driver added"{
                            let alert = UIAlertController(title: "Driver Successfully Added", message: "Driver successfully added to your organization", preferredStyle: .alert)
                            let ok=UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(alert, animated: true)
                                self.textField.text=""
                                self.fetchDrivers()
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
    
    func fetchDrivers(){
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
                        print(jsonResult)
                        let response = jsonResult["response"] as! NSDictionary
                        let users = response["users"] as! NSMutableArray
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
                    
                }
            }
            task.resume()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate = self
        tableView.rowHeight=155
        print("OrgID is \(orgID!)")
        fetchDrivers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension AdminDriversVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminDriverCell", for: indexPath) as! AdminDriverCell
        let currentDriver = tableData[indexPath.row]
        cell.nameLabel.text = (currentDriver["first_name"] as! String) + " " + (currentDriver["last_name"] as! String)
        cell.emailLabel.text=currentDriver["email"] as! String
        cell.phoneLabel.text=(currentDriver["phone_number"] as! String)
        return cell
    }
    
    
}
