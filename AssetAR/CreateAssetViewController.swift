//
//  CreateAssetViewController.swift
//  AssetAR
//
//  Created by Jules on 21/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import CoreLocation

class CreateAssetViewController:UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet var assetName: UITextField!
    @IBOutlet var lattitude: UITextField!
    @IBOutlet var longitude: UITextField!
    
    let locationManager = CLLocationManager()
    
    @IBAction func back(_ sender: Any) {
        self.goHome()
    }
    
    @IBAction func createAsset(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let _assetName = self.assetName.text!
        let _lattitude = self.lattitude.text!
        let _longitude = self.longitude.text!
        if(!_assetName.isEmpty && !_lattitude.isEmpty && !_longitude.isEmpty){
            print(!_assetName.isEmpty)
            if(self.addAsset(_assetName: _assetName, _lattitude: _lattitude, _longitude: _longitude)){
                UIViewController.removeSpinner(spinner: sv)
                self.goHome()
            } else{
                UIViewController.removeSpinner(spinner: sv)
                let alert = UIAlertController(title: "Error", message: "Please make sure all information is correctley filled out", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else{
            UIViewController.removeSpinner(spinner: sv)
            let alert = UIAlertController(title: "Error", message: "Please make sure all information is correctley filled out", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }


    func addAsset(_assetName:String,_lattitude:String,_longitude:String) -> Bool{
        var status = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            SessionManager.shared.credentialsManager.credentials { error, credentials in
                guard error == nil, let credentials = credentials else {
                    status = false
                    group.leave()
                    return
                }
                let dictionaryData = ["name":"\(_assetName)","assetX":_lattitude,"assetY":_longitude,"orginizationID":1] as [String : Any]
                print("{'name':'\(_assetName)','assetX':\(_lattitude),'assetY':\(_longitude),'orginizationID':1}")
                let headers = ["content-type": "application/json"]
                var postData = NSData()
                do{
                    postData = try JSONSerialization.data(withJSONObject: dictionaryData) as NSData
                } catch {
                    print(error)
                    group.leave()
                }
                print("headers = \(headers.description)")
                let url = URL(string: "http://assetar-stg.herokuapp.com/api/insert/asset")
                var request = URLRequest(url: url!)
                
                request.httpMethod = "POST"
                request.addValue("Bearer \(credentials.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                request.allHTTPHeaderFields = headers
                request.httpBody = postData as Data
                request.cachePolicy = .useProtocolCachePolicy
                request.timeoutInterval = 10.0
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if (error != nil) {
                        print(error ?? "")
                        status = false
                        group.leave()
                     //   UIViewController.removeSpinner(spinner: sv)
                    } else {
                        let httpResponse = response
                        print(httpResponse ?? "")
                        guard let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
                            print("Can not convert data to JSON object")
                           // UIViewController.removeSpinner(spinner: sv)
                            status = false
                            group.leave()
                            return
                        }
                        print(json)
                        status = true
                        group.leave()
                    }
                    
                }).resume()
            }
        }
        group.wait()
        return status
    }
    
    @IBAction func getLocation(_ sender: Any) {
        lattitude.text! = (locationManager.location?.coordinate.latitude.description)!
        longitude.text! = (locationManager.location?.coordinate.longitude.description)!
    }
    
    func goHome(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.present(vc, animated: true, completion: {
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
}
