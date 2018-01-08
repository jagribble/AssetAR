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

class HomeController:UIViewController{
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func signUp(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as UIViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    func loginCustom(){
        
        Auth0.authentication().login(usernameOrEmail: userName.text!, password: password.text!, realm: "Username-Password-Authentication", audience: "https://assetar-stg.herokuapp.com/", scope: "openid profile offline_access").start{
            switch $0 {
                                case .failure(let error):
                                    // Handle the error
                                    print("Error: \(error)")
                                case .success(let credentials):
                                    // Do something with credentials e.g.: save them.
                                    // Auth0 will automatically dismiss the hosted login page
                                    print("Credentials: \(credentials)")
                                    print(credentials.accessToken ?? "no access token");
                                   // print(credentials.refreshToken ?? "no access token");
                                SessionManager.shared.storeTokens(credentials.accessToken!,idToken:credentials.idToken!)
                                    SessionManager.shared.store(credentials: credentials)
        }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        loginCustom()
//        var buffer = [UInt8](repeating: 0, count: 32)
//        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
//        let verifier = Data(bytes: buffer).base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-")
//            .replacingOccurrences(of: "/", with: "")
//            .replacingOccurrences(of: "=", with: "")
//            .trimmingCharacters(in: .whitespaces)
//        // You need to import CommonCrypto
//        guard let data = verifier.data(using: .utf8) else {
//            return;
//        }
//        buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
//        data.withUnsafeBytes {
//            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
//        }
//        SessionManager.shared.verifier = verifier
//        let hash = Data(bytes: buffer)
//        let challenge = hash.base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-")
//            .replacingOccurrences(of: "/", with: "")
//            .replacingOccurrences(of: "=", with: "")
//            .trimmingCharacters(in: .whitespaces)
//        SessionManager.shared.challenge = challenge
//
//        let url = URL(string:"https://app79553870.auth0.com/authorize?audience=https://assetar-stg.herokuapp.com/&scope=profile&response_type=code&client_id=2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z&code_challenge=\(challenge)&code_challenge_method=S256&redirect_uri=Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback")
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//
//        //"https://app79553870.auth0.com/authorize?audience=https://assetar-stg.herokuapp.com/&scope=profile&response_type=code&client_id=2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z&code_challenge=\(challenge)&code_challenge_method=S256&redirect_uri=Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback"
//
////        Auth0
////            .webAuth()
////            .scope("openid profile offline_access")
////            .audience("https://app79553870.auth0.com/userinfo")
////            .start {
////                switch $0 {
////                case .failure(let error):
////                    // Handle the error
////                    print("Error: \(error)")
////                case .success(let credentials):
////                    // Do something with credentials e.g.: save them.
////                    // Auth0 will automatically dismiss the hosted login page
////                    print("Credentials: \(credentials)")
////                    print(credentials.accessToken ?? "no access token");
////                    print(credentials.refreshToken ?? "no access token");
////                    SessionManager.shared.storeTokens(credentials.accessToken!,idToken:credentials.idToken!)
////                    SessionManager.shared.store(credentials: credentials)
////                    codeVerifier()
////                }
////        }
   }
    
    // Create an instance of the credentials manager for storing credentials
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    /**
    
     
     **/
    
}


