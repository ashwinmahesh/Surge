//
//  AdminWaitVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class AdminWaitVC: UIViewController {
    var orgNameText:String?

    @IBOutlet weak var orgNameLabel: UILabel!
    @IBAction func backPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "WaitToHomeSegue", sender: "WaitToHome")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        orgNameLabel.text = orgNameText!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
