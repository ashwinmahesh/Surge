//
//  HomeVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    var tableData:[String]=[]
    @IBOutlet weak var tableView: UITableView!
    @IBAction func logoutPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeToLoginSegue", sender: "HomeToLogin")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationCell", for: indexPath)
        
        return cell
    }
    
    
}
