//
//  ViewController.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBAction func registerPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToRegisterSegue", sender: "LoginToRegister")
    }
    
    @IBAction func loginPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToHomeSegue", sender: "LoginToHome")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

