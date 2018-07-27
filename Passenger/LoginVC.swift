//
//  ViewController.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewInsideScroll: UIView!
    var result:NSDictionary=[:]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func registerPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToRegisterSegue", sender: "LoginToRegister")
    }
    
    @IBAction func loginPushed(_ sender: UIButton) {
        if clientValidate(){
            var valid=false
            if let urlReq = URL(string: "\(SERVER.IP)/processLogin/"){
                var request = URLRequest(url:urlReq)
                request.httpMethod = "POST"
                let bodyData="email=\(emailField.text!)&password=\(passwordField.text!)"
                request.httpBody = bodyData.data(using: .utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest){
                    data, response, error in
                    do{
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                            let response = jsonResult["response"] as! String
//                            print("Response: \(response)")
                            self.result=jsonResult
//                            print(jsonResult)
                            if response == "User does not exist"{
                                DispatchQueue.main.async{
                                    self.alert(title: "Login failed", message: "User does not exist")
                                }
                            }
                            else if response == "Password does not match user"{
                                DispatchQueue.main.async{
                                    self.alert(title: "Login Failed", message: "Password does not match user")
                                }
                            }
                            else if response == "Login successful"{
                                DispatchQueue.main.async{
                                    valid=true
                                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: "LoginToHome")
                                }
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                task.resume()
                print(valid)

            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let request:NSFetchRequest<User> = User.fetchRequest()
        do{
            let fetchResult = try context.fetch(request)
//            print("Result is: ",fetchResult)
//            print("Count is: ", fetchResult.count)
            if fetchResult.count>0{
//                print("Inside the if statement")
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: "AlreadyLoggedIn")
                }
            }
        }
        catch{
            print(error)
        }
        self.hideKeyboard()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sent = sender as? String{
            if sent=="LoginToHome"{
//                print("Entering here")
//                print("Result is: ")
                let newUser = User(context:self.context)
                newUser.first_name = result["first_name"] as! String
                newUser.last_name = result["last_name"] as! String
                newUser.email = result["email"] as! String
                newUser.id = result["id"] as! Int64
                newUser.phone_number = result["phone_number"] as! String
                appDelegate.saveContext()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: nil))
        self.present(alert, animated:true)
    }
    
    func clientValidate() -> Bool{
        if emailField.text!.count<5{
            DispatchQueue.main.async{
                self.alert(title: "Login Failed", message: "Invalid email")
            }
            return false
        }
        if passwordField.text!.count<8{
            DispatchQueue.main.async{
                self.alert(title: "Login Failed", message: "Password must be atleast 8 characters")
            }
            return false
        }
        return true
    }

}
extension UIViewController{
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
extension LoginVC:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
