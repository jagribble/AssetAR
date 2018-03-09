//
//  HomeViewController.swift
//  AssetAR
//
//  Created by Jules on 16/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit

class HomeViewController:UIViewController{
    var assetArray:[Asset] = []
    
    @IBOutlet var welcomeMessage: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var arButton: UIButton!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var addAssetButton: UIButton!
    @IBOutlet var assetListButton: UIButton!
    
    
    @IBAction func logout(_ sender: Any) {
        SessionManager.shared.logout()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as? LoginViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func displayList(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ListView") as? AssetListView {
            if(self.getAssets()){
                
                viewController.assetArray = assetArray
                self.present(viewController, animated: true, completion: {
                    UIViewController.removeSpinner(spinner: sv)
                })
            }
        }
    }
    
    /**
     Function to get all assets
     **/
    func getAssets() -> Bool{
        var status = false
        let group = DispatchGroup()
        group.enter()
        let sv = UIViewController.displaySpinner(onView: self.view)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            // set up the request
            
            SessionManager.shared.credentialsManager.credentials { error, credentials in
                guard error == nil, let credentials = credentials else {
                    // Handle Error
                    // Route user back to Login Screen
                    return
                }
                print("Access Token \(credentials.accessToken ?? "NO access token tstored")")
                let url = URL(string: "https://assetar-stg.herokuapp.com/api/\(SessionManager.shared.organisation!)/assets")
                var request = URLRequest(url: url!)
                // Configure your request here (method, body, etc)
                request.addValue("Bearer \(credentials.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                print("Bearer \(credentials.accessToken ?? "")")
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    UIViewController.removeSpinner(spinner: sv)
                    guard let data = data else {
                        let alert = UIAlertController(title: "Error", message: "Can not get Assets please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        status = false
                        group.leave()
                        return
                    }
                    print(response!)
                    
                    // when the repsonse is returned output response
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject] else {
                        print("Can not convert data to JSON object")
                        status = false
                        group.leave()
                        return
                    }
                    
                    print("----------------------------------")
                    print(json!)
                    print("----------------------------------")
                    let assets = json!["rows"]! as! NSArray
                    var i = 0
                    while i<assets.count{
                        let instance = assets[i] as! [String:AnyObject]
                        let asset = Asset(id: instance["assetid"] as! Int ,name: instance["assetname"] as! String, x: instance["assetx"] as! Float , z: instance["assety"] as! Float,oId: instance["orginizationid"] as! Int) 
                        self.assetArray.append(asset)
                        i = i+1
                    }
                    status = true
                    group.leave()
                    //  self.placeAssets()
                })
                task.resume()
                
            }
        }
        group.wait()
        return status
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(SessionManager.shared.organisation)
        //SessionManager.shared.retrieveProfile()
//        if(SessionManager.shared.getOrganization()){
//            let alert = UIAlertController(title: "Success", message: "Orgaisation \(SessionManager.shared.organisation!)", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//
//        }
////        if(true){
//            let alert = UIAlertController(title: "Success", message: "Orgaisation \(SessionManager.shared.organisation!)", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
////
//        }
       // SessionManager.shared.retrieveProfile()
        
        if (SessionManager.shared.organisation == nil){
            
            if(SessionManager.shared.getOrganization()){
                welcomeMessage.text = "Welcome, \(SessionManager.shared.userProfile!.name!)"
                message.isHidden = true
                let alert = UIAlertController(title: "Success", message: "Orgaisation \(SessionManager.shared.organisation!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else{
                let alert = UIAlertController(title: "Error", message: "Can not get orgaisation! Please ask admin to assign you to an orgaisation", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                welcomeMessage.text = "Welcome, \(SessionManager.shared.userProfile!.name!)"
                
                arButton.isEnabled = false;
                mapButton.isEnabled = false;
                addAssetButton.isEnabled = false;
                assetListButton.isEnabled = false;
            }
        } else{
             welcomeMessage.text = "Welcome, \(SessionManager.shared.userProfile!.name!)"
            message.isHidden = true
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
}
