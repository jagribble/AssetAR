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
import SafariServices

class LoginViewController:UIViewController{
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func signUp(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as UIViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    func loginCustom(){
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        SessionManager.shared.login(userName: userName.text!, password: password.text!) 
        { (status) in
            if(status){
                // successfully logged in
                UIViewController.removeSpinner(spinner: sv)
              
                self.goHome()
            }
            else{
                UIViewController.removeSpinner(spinner: sv)
                let alert = UIAlertController(title: "Failed", message: "Please check email or password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
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
            self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func login(_ sender: Any) {
       
        loginCustom()

   }
    
    // Create an instance of the credentials manager for storing credentials
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    override func viewDidAppear(_ animated: Bool) {
        SessionManager.shared.renewAuth { (error) in
            if(error != nil){
                print("Not logged in")
                // self.loginCustom()
            } else {
                print("Already Logged in")
                self.goHome()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SessionManager.shared.renewAuth { (error) in
            if(error != nil){
                print("Not logged in")
                // self.loginCustom()
            } else {
                print("Already Logged in")
                self.goHome()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.goHome()
        SessionManager.shared.renewAuth { (error) in
            if(error != nil){
                print("Not logged in")
               // self.loginCustom()
            } else {
                print("Already Logged in")
                self.goHome()
            }
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    /**
    
     
     **/
    
}


