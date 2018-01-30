//
//  SignUpViewController.swift
//  AssetAR
//
//  Created by Jules on 08/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import Auth0

class SignUpViewController:UIViewController{
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func cancel(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as UIViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let group = DispatchGroup()
        var errorString = ""
        var status = false
        let _email = email.text!
        let _password = password.text!
        let _firstName = firstName.text!
        let _lastName = lastName.text!
        group.enter()
         DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            Auth0
                .authentication()
                .createUser(
                    email: "\(_email)",
                    password: "\(_password)",
                    connection: "Username-Password-Authentication",
                    userMetadata: ["first_name": "\(_firstName)",
                                   "last_name": "\(_lastName)"]
                )
                .start { result in
                    switch result {
                    case .success(let user):
                        print("User Signed up: \(user)")
                        status = true
                        group.leave()
                   
                    
                    case .failure(let error):
                        print("Failed with \(error)")
                        errorString = error.localizedDescription
                        status = false
                        group.leave()
                      
                    }
            }
        }
        group.wait()
        if(status){
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as UIViewController
            self.present(viewController, animated: true, completion: {
                UIViewController.removeSpinner(spinner: sv)
            })
        } else{
            UIViewController.removeSpinner(spinner: sv)
            let alert = UIAlertController(title: "Alert", message: "\(errorString)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    
}

