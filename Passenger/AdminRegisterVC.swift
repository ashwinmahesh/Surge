//
//  AddOrgVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class AdminRegisterVC: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func backPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func applyPushed(_ sender: UIButton) {
        if nameField.text!.count<6{
            let alert = UIAlertController(title:"Invalid Entry", message:"Organization name must be atleast 6 characters to keep every group unique", preferredStyle: .alert)
            let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated:true)
            return
        }
        if descriptionView.text!.count<150{
            let alert = UIAlertController(title:"Invalid Entry", message:"Organization description must be atleast 150 characters so we can get a better idea of who you are to prevent fraudulent activity (That's just 2 sentences!)", preferredStyle: .alert)
            let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated:true)
            return
        }
        if descriptionView.text!.count>300{
            let alert = UIAlertController(title:"Invalid Entry", message:"Organization description only needs to be 300 characters! Be more concise about who you are!", preferredStyle: .alert)
            let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated:true)
            return
        }
        
        let alert = UIAlertController(title:"Confirm", message: "Are you sure this information is correct?", preferredStyle: .alert)
        let yes = UIAlertAction(title:"Yes", style:.default, handler:{
            action in
            self.sendData()
//            self.performSegue(withIdentifier: "AddToFinishSegue", sender: "AddToFinish")
        })
        let no = UIAlertAction(title:"No", style:.cancel, handler:nil)
        alert.addAction(yes)
        alert.addAction(no)
        
        self.present(alert, animated:true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sentName = sender as? String{
            let dest = segue.destination as! AdminWaitVC
            dest.orgNameText = sentName
            dest.fromReg = true
        }
    }
    
    @IBAction func unwindFromWaitVC(segue: UIStoryboardSegue){
        dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData(){
        var id:Int64 = -1
        let request:NSFetchRequest<User> = User.fetchRequest()
        do{
            let result = try context.fetch(request).first
            id=result!.id
        }
        catch{
            print(error)
        }
        
        if let urlReq = URL(string: "\(SERVER.IP)/processOrgRegister/"){
            var request = URLRequest(url:urlReq)
            request.httpMethod="POST"
            let bodyData = "name=\(nameField.text!)&description=\(descriptionView.text!)&userID=\(id)"
            request.httpBody=bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest){
                data, response, error in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        let response = jsonResult["response"] as! String
                        print(response)
                        if response == "invalid"{
                            DispatchQueue.main.async{
                                let alert = UIAlertController(title:"Invalid Entry", message:"An organization already exists with this name. Try being more specific!", preferredStyle: .alert)
                                let ok = UIAlertAction(title:"OK", style:.default, handler:nil)
                                alert.addAction(ok)
                                self.present(alert, animated:true)
                                return
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                self.performSegue(withIdentifier: "AddToFinishSegue", sender: self.nameField.text!)
                            }
                        }
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

