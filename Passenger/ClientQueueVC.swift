//
//  ClientQueueVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
import CoreData

class ClientQueueVC: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var orgID:Int?
    var id:Int64?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var queueLabel: UILabel!
    @IBAction func backPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "QueueToHomeSegue", sender: "QueueToHome")
    }
    @IBAction func cancelPushed(_ sender: UIButton) {
        removeFromQueue()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OrgID: \(orgID!)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        getPosition()
    }
    

    func getPosition(){
        id = -1
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        do{
            let user = try context.fetch(fetchRequest).first!
            id = user.id
        }
        catch{
            print(error)
        }
        
        let url = URL(string: "\(SERVER.IP)/getQueuePosition/")
        var request = URLRequest(url: url!)
        request.httpMethod="POST"
        let bodyData="orgID=\(orgID!)&userID=\(id!)"
        request.httpBody = bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                    print(jsonResult)
                    let response = jsonResult["response"] as! String
                    if response=="bad"{
                        let alert = UIAlertController(title: "Fetch Error", message: "We could not get your position in the queue. Try again.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                            return
                        })
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
                        }
                    }
                    let position = jsonResult["position"] as! Int
                    let name=jsonResult["organization"] as! String
                    DispatchQueue.main.async{
                        self.queueLabel.text = "You are #\(position) in the queue"
                        self.nameLabel.text = name
                    }
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    func removeFromQueue(){
        let url = URL(string: "\(SERVER.IP)/removeFromQueue/")
        var request = URLRequest(url: url!)
        request.httpMethod="POST"
        let bodyData="userID=\(id!)"
        request.httpBody = bodyData.data(using:.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                    print(jsonResult)
                    let response = jsonResult["response"] as! String
                    if response=="success"{
                        let alert = UIAlertController(title: "Success", message: "Successfully removed from the queue!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                            DispatchQueue.main.async{
                                self.performSegue(withIdentifier: "QueueToHomeSegue", sender: "QueueToHome")
                            }
                        })
                        alert.addAction(ok)
                        DispatchQueue.main.async{
                            self.present(alert, animated: true)
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
