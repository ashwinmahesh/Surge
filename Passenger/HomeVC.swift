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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var tableData:[String]=["Pike"]
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
        tableView.rowHeight=100

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let sentMessage = sender as? String{
//            if sentMessage == "HomeToAdmin"{
//                let dest = segue.destination as! AdminMainVC
//                dest.fetchOrganizations()
//            }
//        }
    }

}
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationCell", for: indexPath) as! OrganizationCell
        cell.organizationLabel.text = "Pi Kappa Alpha"
        cell.driverCountLabel.text = "Drivers: 2"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AllToOneOrgSegue", sender: "AllToOneOrg")
//        performSegue(withIdentifier: "HomeToClientQueueSegue", sender: "HomeToClientQueue")
    }
    
    
}
