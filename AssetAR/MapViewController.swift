//
//  MapViewController.swift
//  AssetAR
//
//  Created by Jules on 21/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import MapKit
class MapViewController:UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    let locationManager = CLLocationManager()
    var assetArray:[Asset] = []
    @IBAction func back(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as? HomeViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     Function to get all assets
     **/
    func getAssets(){
        // set up the request
        let sv = UIViewController.displaySpinner(onView: self.view)
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
                    return
                }
                print(response!)
                
                // when the repsonse is returned output response
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject] else {
                    print("Can not convert data to JSON object")
                    return
                }
                
                print("----------------------------------")
                print(json!)
                print("----------------------------------")
                let assets = json!["rows"]! as! NSArray
                var i = 0
                while i<assets.count{
                    let instance = assets[i] as! [String:AnyObject]
                    let asset = Asset(id: instance["assetid"] as! Int ,name: instance["assetname"] as! String, x: instance["assetx"]?.floatValue as! Float , z: instance["assety"]?.floatValue as! Float,oId: instance["orginizationid"] as! Int)  
                    self.assetArray.append(asset)
                    i = i+1
                }
                self.placeAssets()
            })
            task.resume()
        }
        
        
    }
    
    func placeAssets(){
        print("ASSETS = \(assetArray.count)")
        var annotaions:[MapAnnotation] = []
        for asset in assetArray{
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(asset.assetLocationX), longitude: CLLocationDegrees(asset.assetLocationZ))
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = location.distance(from: locationManager.location!).rounded(FloatingPointRoundingRule.toNearestOrEven)
            let mapAnnotation = MapAnnotation(t: asset.assetName, s: distance.description, cord: coordinate)
            annotaions.append(mapAnnotation)
            print("asset = \(asset.assetName), \(mapAnnotation)")
        }
        self.mapView.addAnnotations(annotaions)
       
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationManager.stopUpdatingLocation()
        self.centerMapOnLocation(location: manager.location!)
        self.getAssets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = true
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        self.hideKeyboardWhenTappedAround()
    }
}
