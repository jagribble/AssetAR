//
//  AssetDetailViewController.swift
//  AssetAR
//
//  Created by Jules on 23/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit

class AssetDetailViewController:UIViewController,UINavigationControllerDelegate{
    
    @IBOutlet var assetName: UILabel!
    @IBOutlet var lattitude: UILabel!
    @IBOutlet var longitude: UILabel!
    @IBOutlet var organisation: UILabel!
    
    var asset:Asset? = nil
    
    @IBAction func back(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        self.performSegue(withIdentifier: "goBackToList", sender: self)
    }
    
    @IBAction func deleteAsset(_ sender: Any) {
        let alert = UIAlertController(title: "Delete '\(self.asset?.assetName ?? "")'",
                                      message: "Are you sure you want to delete the asset '\(self.asset?.assetName ?? "")'",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
            if(self.deleteAssets(assetID: (self.asset?.id)!)){
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as? HomeViewController {
                    self.present(viewController, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Can not delete assets please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert,animated: true,completion: nil)
        
       
        
    }
    
    func deleteAssets(assetID:Int)->Bool{
        var status = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            SessionManager.shared.credentialsManager.credentials { error, credentials in
                guard error == nil, let credentials = credentials else {
                    // Handle Error
                    // Route user back to Login Screen
                    return
                }
                print("Access Token \(credentials.accessToken ?? "NO access token tstored")")
                let url = URL(string: "https://assetar-stg.herokuapp.com/delete/"+String(assetID))
                var request = URLRequest(url: url!)
                request.httpMethod = "DELETE"
                // Configure your request here (method, body, etc)
                request.addValue("Bearer \(credentials.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                print("Bearer \(credentials.accessToken ?? "")")
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    guard let data = data else {
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
                   
                    status = true
                    group.leave()
                })
                task.resume()
                
            }
        }
        group.wait()
        return status
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.delegate = self
        if(asset != nil){
            assetName?.text = asset?.assetName
            lattitude?.text = asset?.assetLocationX.description
            longitude?.text = asset?.assetLocationZ.description
            organisation?.text = asset?.orgainsationID.description
        }
      
    }
}
