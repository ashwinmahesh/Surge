//
//  ClientQueueVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class ClientQueueVC: UIViewController {

    @IBOutlet weak var queueLabel: UILabel!
    @IBAction func backPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "QueueToHomeSegue", sender: "QueueToHome")
    }
    @IBAction func cancelPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "QueueToHomeSegue", sender: "QueueToHome")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
