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
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var objectSet = false
    @IBOutlet var sceneView: ARSCNView!
    
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
            let url = URL(string: "https://assetar-stg.herokuapp.com/assets")
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
       
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.getAssets()
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
       // guard let pin = SCNScene(named: "art.scnassets/galaxy.dae") else {return}
        
        let ballNode = SCNNode(geometry: ballShape)
        //let ballNode = SCNNode()
//        ballNode.addChildNode(pin.rootNode)
//        ballNode.scale = SCNVector3Make(0.1,0.1,0.1)
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
     
            // stanlake park windsor wine estate
            let asset1 = Asset(name: "Asset1", x: 51.470032, z: -0.849879)
                // elephant and castle
            let asset2 = Asset(name: "Asset2", x: 51.461792, z:  -0.860224)
            let asset3 = Asset(name:"Asset 3",x:51.471721, z: -0.861691)
            let asset4 = Asset(name:"Asset 4",x:51.463258, z: -0.851843)
           //* work out the location relative to the point the device is
           //https://www.raywenderlich.com/146436/augmented-reality-ios-tutorial-location-based-2
           // To get directions in gravity&Heading see https://developer.apple.com/documentation/arkit/arconfiguration.worldalignment/2873776-gravityandheading */
            
            let ballNodeX:Float
            let ballNodeZ:Float
            
            print("user Long = (\(Float(locValue.longitude)),\(Float(locValue.latitude))")
            print("asset Long = (\(asset1.assetLocationZ),\(asset1.assetLocationX))")
     
            ballNodeX = ((asset1.assetLocationX)-(Float(locValue.latitude) ))//East/West
            ballNodeZ = (Float(locValue.longitude)-(asset1.assetLocationZ))//North/South
            
            print("ballNodeX = \(ballNodeX*10000),    ballNodeZ = \(ballNodeZ*10000)")
            // If either (not both) values are negative keep same position otherwise take the negative positions (flip the axis)
            // This takes into acccount the four quadrants
            if((ballNodeZ < 0 && ballNodeX > 0) || (ballNodeX < 0 && ballNodeZ > 0)){
                ballNode.position = SCNVector3Make(ballNodeX*10000,0, ballNodeZ*10000)
            } else if((ballNodeZ > 0 && ballNodeX > 0) || (ballNodeZ < 0 && ballNodeX < 0)){
                ballNode.position = SCNVector3Make(-ballNodeX*10000,0, -ballNodeZ*10000)
            }
       
       // ballNode.scale = SCNVector3(0.25, 0.25, 0.25)
      //  ballNode.position = SCNVector3Make(ballNodeX*10000,0, ballNodeZ*10000)
       // ballNode.position = SCNVector3Make(0,0, -2)
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {return}
//        let result = sceneView.hitTest(touch.location(in: sceneView), types: ARHitTestResult.ResultType.featurePoint)
//        // get the last result as that will be most accurate
//        guard let hitResult = result.last else {return}
//        let hitTransform =  hitResult.worldTransform
//        let hitVector = SCNVector3Make(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
//        
//        createBall(position: hitVector)
//        
//        
        
    }
    
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
