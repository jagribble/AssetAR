//
//  Home.swift
//  AssetAR
//
//  Created by Jules on 02/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import Auth0

class HomeController:UIViewController{
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    // Create an instance of the credentials manager for storing credentials
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    
    override func viewDidLoad() {
        
        
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
            .audience("https://app79553870.auth0.com/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the hosted login page
                    print("Credentials: \(credentials)")
                    print(credentials.accessToken ?? "no access token");
                    SessionManager.shared.storeTokens(credentials.accessToken!,idToken:credentials.idToken!)
                    SessionManager.shared.store(credentials: credentials)
                    codeVerifier()
                }
        }
    }
    
    /**
    
     
     **/
    
}


