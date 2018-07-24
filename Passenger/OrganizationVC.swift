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
    
    var tableData:[String]=["Ashwin"]

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
        print("Org id: \(orgID)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension OrganizationVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as! DriverCell
        cell.nameLabel.text="Ashwin Mahesh"
        cell.phoneLabel.text = "(408) 644-9017"
        return cell
    }
}
