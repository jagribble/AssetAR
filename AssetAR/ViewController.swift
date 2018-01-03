//
//  ViewController.swift
//  AssetAR
//
//  Created by Jules on 11/10/2017.
//  Copyright © 2017 Gribble. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import Auth0
import SimpleKeychain

class ViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var objectSet = false
    @IBOutlet var sceneView: ARSCNView!
    
    /**
     Function to get all assets
     **/
    func getAssets(){
        // set up the request
        print("Access Token \(SessionManager.shared.credentials?.accessToken ?? "NO access token tstored")")
        let url = URL(string: "https://assetar-stg.herokuapp.com/assets")
        var request = URLRequest(url: url!)
        // Configure your request here (method, body, etc)
        request.addValue("Bearer \(SessionManager.shared.credentials?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        print("Bearer \(SessionManager.shared.credentials?.accessToken ?? "")")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                print("No data in url")
                return
            }
            print(response)
            // when the repsonse is returned output response
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                print("Can not convert data to JSON object")
                return
            }
            
            print("----------------------------------")
            print(json)
            print("----------------------------------")
        })
        task.resume()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else{
            print("location manager disabled")
        }
        let ballShape = SCNSphere(radius: 0.09)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/texture.png")
        ballShape.materials = [material]
        let ballNode = SCNNode(geometry: ballShape)
        ballNode.position = SCNVector3Make(0,0, -1)
        sceneView.scene.rootNode.addChildNode(ballNode)
        //51.441431, -0.941817
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(!objectSet){
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
       // print("locations = \(locValue.latitude) \(locValue.longitude)")
       // print("location data -> \(String(describing: manager.location))")
        let ballShape = SCNSphere(radius: 1.19)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/pin.jpg")
        ballShape.materials = [material]
        let ballNode = SCNNode(geometry: ballShape)
     
        
        let asset1 = Asset(name: "Asset1", x: 51.451653, z: -0.951794)
        let asset2 = Asset(name: "Asset2", x: 51.441431, z: -0.941817)
       //* work out the location relative to the point the device is
       //https://www.raywenderlich.com/146436/augmented-reality-ios-tutorial-location-based-2
       // To get directions in gravity&Heading see https://developer.apple.com/documentation/arkit/arconfiguration.worldalignment/2873776-gravityandheading */
        
        let ballNodeX:Float
        let ballNodeZ:Float
        // if the users longitude value is less than the x value for the asset then take the current location from the assets else do it the other way
        if(Float(locValue.longitude) < asset2.assetLocationX){
            ballNodeX = ((asset2.assetLocationX)-(Float(locValue.longitude) ))//East/West
        } else{
            ballNodeX = (Float(locValue.longitude)-(asset2.assetLocationX))//East/West
        }
        
          // if the users longitude value is less than the z value for the asset then take the current location from the assets else do it the other way
        if(Float(locValue.latitude) < asset2.assetLocationZ){
             ballNodeZ = ( (asset2.assetLocationZ)-(Float(locValue.latitude) ))//North/South
        } else{
            ballNodeZ = (Float(locValue.latitude)-(asset2.assetLocationZ))//North/South
        }
       
        print("ballNodeX = \(ballNodeX),    ballNodeZ = \(ballNodeZ)")
        ballNode.position = SCNVector3Make(ballNodeX,0, ballNodeZ)
        sceneView.scene.rootNode.addChildNode(ballNode)
            objectSet = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //detect planes and set the heading of the ARKit world to the heading of north
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        self.getAssets()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
