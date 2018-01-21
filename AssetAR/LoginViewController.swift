//
//  Home.swift
//  AssetAR
//
//  Created by Jules on 02/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import Auth0
import CommonCrypto
import LocalAuthentication
import SafariServices

class LoginViewController:UIViewController{
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    var sv: UIView = UIView()
    @IBAction func signUp(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as UIViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    func loginCustom(){
        
        sv = UIViewController.displaySpinner(onView: self.view)
        
        let value = SessionManager.shared.login(userName: userName.text!, password: password.text!)
        if(value){
           
            self.goHome()
        }
        else{
            UIViewController.removeSpinner(spinner: self.sv)
            let alert = UIAlertController(title: "Failed", message: "Please check email or password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
//        { (status) in
//            if(status){
//                // successfully logged in
//
//
//                self.goHome()
//            }
//            else{
//                UIViewController.removeSpinner(spinner: self.sv)
//                let alert = UIAlertController(title: "Failed", message: "Please check email or password", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//
//            }
//
//        }
      
        
//        Auth0.authentication().login(usernameOrEmail: userName.text!, password: password.text!, realm: "Username-Password-Authentication", audience: "https://assetar-stg.herokuapp.com/", scope: "openid profile").start{
//            switch $0 {
//                                case .failure(let error):
//                                    // Handle the error
//                                    UIViewController.removeSpinner(spinner: sv)
//                                    print("Error: \(error)")
//                                    let alert = UIAlertController(title: "Failed", message: "Please check email or password", preferredStyle: UIAlertControllerStyle.alert)
//                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                                    self.present(alert, animated: true, completion: nil)
//                                case .success(let credentials):
//                                   
//                                    // Do something with credentials e.g.: save them.
//                                    // Auth0 will automatically dismiss the hosted login page
//                                    print("Credentials: \(credentials)")
//                                    print(credentials.accessToken ?? "no access token");
//                                   
//                                   // print(credentials.refreshToken ?? "no access token");
//                                //SessionManager.shared.storeTokens(credentials.accessToken!,idToken:credentials.idToken!)
//                                    SessionManager.shared.credentialsManager.store(credentials: credentials)
//                                    self.goHome()
//                                    UIViewController.removeSpinner(spinner: sv)
//       
//                
//        }
//        }
        
    }
    
    func goHome(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.present(vc, animated: true, completion: {
                 UIViewController.removeSpinner(spinner: self.sv)
            })
        
    }
    
    @IBAction func login(_ sender: Any) {
       
        loginCustom()

   }
    
    // Create an instance of the credentials manager for storing credentials
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    override func viewDidAppear(_ animated: Bool) {
        if(self.biometrics()){
            self.goHome()
        }
    }
    
    func biometrics()->Bool{
        var status = false
         var error: NSError? = nil
       
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if(error != nil){
            return false
        }
      //  UIApplication.shared.is
        // need to return false if face/touch ID is turned off
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            SessionManager.shared.renewAuth { (error) in
                if(error != nil){
                    print("Not logged in")
                    status = false
                    group.leave()
                    // self.loginCustom()
                } else {
                    status = true
                    print("Already Logged in")
                    group.leave()
                   // self.goHome()
                }
            }
        }
        group.wait()
        return status
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if(self.biometrics()){
//            self.goHome()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.goHome()
       
        self.hideKeyboardWhenTappedAround()
    }
    
    /**
    
     
     **/
    
}


