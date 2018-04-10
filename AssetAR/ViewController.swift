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
    var assetArray:[Asset] = []
    var assetNodes:[SCNNode] = []
    var locValue:CLLocationCoordinate2D? = nil
    var objectSet = false
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func back(_ sender: Any) {
        print("Go back")
        self.goHome()
    }
    
    func goHome(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as? HomeViewController {
            self.present(viewController, animated: true, completion: nil)
        }
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
            print("Access Token \(credentials.accessToken ?? "NO access token stored")")
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
                     let asset = Asset(id: instance["assetid"] as! Int ,name: instance["assetname"] as! String, x: instance["assetx"] as! Float , z: instance["assety"] as! Float,oId: instance["orginizationid"] as! Int)
                    self.assetArray.append(asset)
                    i = i+1
                }
                self.drawAssets()
                let asset = assets[0] as! [String:AnyObject]
                print(asset["assetid"])
            })
            task.resume()
        }
       
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else{
            print("location manager disabled")
        }
        self.getAssets()
        let ballShape = SCNSphere(radius: 0.09)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/texture.png")
        ballShape.materials = [material]
      //  guard let pin = SCNScene(named: "art.scnassets/test.dae") else {return}

        let ballNode = SCNNode(geometry: ballShape)

        ballNode.position = SCNVector3Make(0,0, -1)
        sceneView.scene.rootNode.addChildNode(ballNode)
        
        //51.441431, -0.941817
    }
    
    func drawAssets(){
        for asset in assetArray{
            print("------------------")
            let scale = self.getScale(assetLat: asset.assetLocationX, assetLong: asset.assetLocationZ)
            print("AssetName = \(asset.assetName)")

            print("Scale = \(scale.x)")
            let ballShape : SCNGeometry
            let text = SCNText(string: asset.assetName, extrusionDepth: 1.0)
            //if the asset scale is high (close to location) then give it smaller radius
            if(scale.x > 10){
                ballShape = SCNSphere(radius:1)
            } else if (scale.x > 1 && scale.x < 10){
                ballShape = SCNSphere(radius: 10)
            } else{
                // These assets are unlikely to show due to the radius of assets returned by API but if radius is set to high display assets according to their scale factor so they can be seen by the user
                ballShape = SCNSphere(radius: CGFloat(10 / scale.x))
            }

            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "art.scnassets/pin.jpg")
            
            ballShape.materials = [material]
            let ballNode = SCNNode(geometry: ballShape)
//            let ballNodeX:Float
//            let ballNodeZ:Float
//            let location = locationManager.location?.coordinate
//            let scaleFactor:Float = 1000
            

            ballNode.worldPosition = self.getTranslation(assetLat: asset.assetLocationX, assetLong: asset.assetLocationZ)
            print("Postion X = \(ballNode.position.x)   postion Z = \(ballNode.position.z)")
            ballNode.scale = scale
            ballNode.movabilityHint = SCNMovabilityHint.fixed
            let spin = CABasicAnimation(keyPath: "rotation")
            // Use from-to to explicitly make a full rotation around z
            spin.fromValue =  SCNVector4Make(0, 1, 0, 0)
            spin.toValue = SCNVector4Make(0, 1, 0, Float(CGFloat(2 * Double.pi)))
            
            spin.duration = 8
            spin.repeatCount = .infinity
            ballNode.addAnimation(spin, forKey: "spin around")
          //  let text = SCNText(string: asset.assetName, extrusionDepth: 1.0)
            let textNode = SCNNode(geometry: text)
            textNode.position = SCNVector3Make(ballNode.position.x,5.0,ballNode.position.z)
//            let ballLocation = CLLocation(latitude: CLLocationDegrees(asset.assetLocationZ), longitude: CLLocationDegrees(asset.assetLocationX))
          
            textNode.scale = SCNVector3(ballNode.scale.x*(2/scale.x),ballNode.scale.y*(2/scale.x),0)
            textNode.simdRotation = (sceneView.pointOfView?.simdRotation)!
            sceneView.scene.rootNode.addChildNode(textNode)
            sceneView.scene.rootNode.addChildNode(ballNode)
            assetNodes.append(ballNode)
            
        }
    }
    
    func updateNodes(){
        for assetNode in assetNodes{
            let asset = assetArray[assetNodes.index(of: assetNode)!]
            let scale = self.getScale(assetLat: asset.assetLocationX, assetLong: asset.assetLocationZ)
            assetNode.worldPosition = self.getTranslation(assetLat: asset.assetLocationX, assetLong: asset.assetLocationZ)
            print("Postion X = \(assetNode.position.x)   postion Z = \(assetNode.position.z)")
            assetNode.scale = scale
        }
    }
    /*
     Code Modifed from https://github.com/ProjectDent/ARKit-CoreLocation/blob/master/ARKit%2BCoreLocation/Source/SceneLocationView.swift
     */
    func getTranslation(assetLat: Float, assetLong:Float) -> SCNVector3{
        let currentLocation = locationManager.location
        let locationNodeLocation = CLLocation(latitude: CLLocationDegrees(assetLat), longitude: CLLocationDegrees(assetLong))
        //Position is set to a position coordinated via the current position
        let locationTranslation = currentLocation?.translation(toLocation: locationNodeLocation)
        let distance = currentLocation?.distance(from: locationNodeLocation)
        print("distance = \(distance)")
        let adjustedDistance: CLLocationDistance
        let scale = 1000 / Float(distance!)
        
        adjustedDistance = distance! * Double(scale)
        print("x = \(locationTranslation?.longitudeTranslation)")
        print("z = \(locationTranslation?.latitudeTranslation)")
        let adjustedTranslation = SCNVector3(
            x: Float((locationTranslation?.longitudeTranslation)!) * scale,
            y: 0,
            z: Float((locationTranslation?.latitudeTranslation)!) * scale)
        
        let position = SCNVector3(
            x:  adjustedTranslation.x,
            y: 0,
            z: adjustedTranslation.z)
        
        return position
        
    }
    
    func getScale(assetLat: Float, assetLong:Float) -> SCNVector3{
        let currentLocation = locationManager.location
        let locationNodeLocation = CLLocation(latitude: CLLocationDegrees(assetLat), longitude: CLLocationDegrees(assetLong))
        let distance = currentLocation?.distance(from: locationNodeLocation)
        let scale = 1000 / Float(distance!)
        return SCNVector3(x: scale, y: scale, z: scale)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //detect planes and set the heading of the ARKit world to the heading of north
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
       
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                print("Number of nodes tapped = \(hits.count)")
            }
        }
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

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
       print("Location manger update")
        self.updateNodes()
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//        self.map.setRegion(region, animated: true)
    }
    
    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
      //  self.updateNodes()
        return node
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
//        let result = sceneView.hitTest(touch.location(in: sceneView), types: ARHitTestResult.ResultType.featurePoint)
////        // get the last result as that will be most accurate
//        guard let hitResult = result.last else {return}
//        let hitTransform =  hitResult.worldTransform
//
//        let hitVector = SCNVector3Make(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
//        
//        createBall(position: hitVector)
//        
//        
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        let alert = UIAlertController(title: "Error", message: "Error with ARKit! Please report to Admin", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.goHome()}))
        self.present(alert, animated: true, completion: {
            self.goHome()
            
        })
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        let alert = UIAlertController(title: "Error", message: "Error with ARKit! Session Interrupted. Please report to Admin", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,  handler: {(alert: UIAlertAction!) in self.goHome()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
