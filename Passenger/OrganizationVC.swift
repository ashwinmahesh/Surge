//
//  OrganizationVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class OrganizationVC: UIViewController {
    var orgID:Int?
    
    var tableData:[NSDictionary]=[]

    @IBOutlet weak var tableView: UITableView!
    @IBAction func backPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func requestRidePushed(_ sender: UIButton) {
        performSegue(withIdentifier: "RequestToConfirmSegue", sender: "RequestToConfirm")
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
