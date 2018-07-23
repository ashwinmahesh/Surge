//
//  DriveQueueVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class DriveQueueVC: UIViewController {
    
    var tableData:[String]=["Ashwin"]

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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension DriveQueueVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath) as! DriveQueueCell
        cell.nameLabel.text = "Ashwin Mahesh"
        cell.addressLabel.text = "6517 Hidden Creek Dr., San Jose"
        cell.statusLabel.text = "Driver: Not Assigned"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DriveQueueToMapSegue", sender: "DriveQueueToMap")
    }
    
    
}
