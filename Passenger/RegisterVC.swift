//
//  RegisterVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    @IBAction func cancelPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func registerPushed(_ sender: UIButton) {
        var valid:Bool?
        if clientSideValidate(){
            if let urlReq = URL(string: "\(SERVER.IP)/processRegister/"){
                var request = URLRequest(url: urlReq)
                request.httpMethod = "POST"
                let bodyData="first_name=\(firstNameField.text!)&last_name=\(lastNameField.text!)&email=\(emailField.text!)&phone=\(phoneField.text!)&password=\(passwordField.text!)"
                request.httpBody = bodyData.data(using: .utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                    do{
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                            print(jsonResult)
                            let result = jsonResult["response"] as! String
                            if result == "bad"{
                                DispatchQueue.main.async{
                                    self.alert(title: "Registration Failed", message: "A user already exists with this email")
                                }
                            }
                            else if result=="Registration successful"{
                                self.dismiss(animated: true, completion: nil)                            }
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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func clientSideValidate() -> Bool{
        if firstNameField.text!.count<2{
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"First name must be atleast two characters")
            }
            return false
        }
        if lastNameField.text!.count<2{
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Last name must be atleast two characters")
            }
            return false
        }
        if emailField.text!.count<5{
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Invalid email address")
            }
            return false
        }
        let email_regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        if email_regex.firstMatch(in: emailField.text!, options: [], range: NSRange(location: 0, length: emailField.text!.count)) == nil {
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Invalid email address")
            }
            return false
        }
        let phone_regex = try! NSRegularExpression(pattern: "^[0-9]{10}$", options: .caseInsensitive)
        if phone_regex.firstMatch(in: phoneField.text!, options: [], range: NSRange(location: 0, length: phoneField.text!.count)) == nil {
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Enter numerical values of phone number only. 1234567890")
            }
            return false
        }
        if passwordField.text!.count<8{
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Password must be atleast 8 characters")
            }
            return false
        }
        if passwordField.text! != confirmField.text!{
            DispatchQueue.main.async{
                self.alert(title:"Registration Failed", message:"Passwords do not match")
            }
            return false
        }
        return true
        
    }
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: nil))
        self.present(alert, animated:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
