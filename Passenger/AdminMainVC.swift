//
//  AdminMainVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class AdminMainVC: UIViewController {

    var tableData:[NSDictionary]=[]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func homePushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminToHomeSegue", sender: "AdminToHome")
    }
    @IBAction func drivePushed(_ sender: UIButton) {
//        performSegue(withIdentifier: "AdminToDriverNoneSegue", sender: "AdminToDriverNone")
        performSegue(withIdentifier: "AdminToDriverSegue", sender: "AdminToDriver")
    }
    @IBAction func addPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminMainToAddSegue", sender: "AdminMainToAdd")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=100
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        print(tableData)
        fetchOrganizations()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchOrganizations(){
        tableData=[]
        var id:Int64 = -1
        let request:NSFetchRequest<User> = User.fetchRequest()
        do{
            let result = try context.fetch(request).first
            id=result!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/getYourOrganizations/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "id=\(id)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        let response = jsonResult["response"] as! NSDictionary
                        let organizations = response["organizations"] as! NSMutableArray
                        for organization in organizations{
                            let orgFixed = organization as! NSDictionary
                            self.tableData.append(orgFixed)
                            print(self.tableData)
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
extension AdminMainVC:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminOrgCell", for: indexPath) as! AdminOrgCell
        let currentOrg=tableData[indexPath.row]
        cell.nameLabel.text = currentOrg["name"] as! String
        let status = currentOrg["approved"] as! Int16
        if status==0{
            cell.statusLabel.text = "Pending"
        }
        else if status==1{
            cell.statusLabel.text = "Approved"
        }
//        cell.nameLabel.text = "Pi Kappa Alpha"
//        cell.statusLabel.text = "Approved"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "AdminMainToWaitSegue", sender: "AdminMainToWait")
        performSegue(withIdentifier: "AdminMainToViewSegue", sender: "AdminMainToView")
    }
}
