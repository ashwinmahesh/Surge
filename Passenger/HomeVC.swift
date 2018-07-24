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
    
    @IBOutlet weak var searchField: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
//        performSegue(withIdentifier: "HomeToDriveNoneSegue", sender: "HomeToDriveNone")
        performSegue(withIdentifier: "HomeToDriveSegue", sender: "HomeToDrive")
    }
    @IBAction func adminPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeToAdminSegue", sender: "HomeToAdmin")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=115
        fetchAllActive()

        // Do any additional setup after loading the view.
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
                        print(jsonResult)
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
        performSegue(withIdentifier: "AllToOneOrgSegue", sender: "AllToOneOrg")
//        performSegue(withIdentifier: "HomeToClientQueueSegue", sender: "HomeToClientQueue")
    }
    
    
}
