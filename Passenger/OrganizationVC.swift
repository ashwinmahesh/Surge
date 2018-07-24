//
//  OrganizationVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class OrganizationVC: UIViewController {
    var orgID:Int?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tableData:[NSDictionary]=[]

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
            let bodyData = "orgID=\(orgID!)&userID=\(id!)"
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
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=100
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
        cell.phoneLabel.text = "(408) 644-9017"
        return cell
    }
}
