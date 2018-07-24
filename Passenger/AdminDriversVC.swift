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
    
    @IBAction func backPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "AdminViewToMainSegue", sender: "AdminViewToMain")
    }
    
    @IBAction func addPushed(_ sender: UIButton) {
        print("Pushing add")
    }
    @IBOutlet weak var textField: UITextField!
    var tableData:[String]=["Ashwin"]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate = self
        tableView.rowHeight=155
        print("OrgID is \(orgID!)")
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
        
        cell.nameLabel.text="Ashwin Mahesh"
        cell.emailLabel.text="mahesh2@purdue.edu"
        cell.phoneLabel.text="(408) 644-9017"
        
        return cell
    }
    
    
}
