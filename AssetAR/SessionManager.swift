//
//  SessionManager.swift
//  AssetAR
//
//  Created by Jules on 02/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//
// Modified from: https://github.com/auth0-samples/auth0-ios-swift-sample/blob/master/03-User-Sessions/Auth0Sample/SessionManager.swift



import Foundation
import Auth0
import LocalAuthentication
import SimpleKeychain

enum SessionManagerError: Error {
    case noAccessToken
}

class SessionManager{
    static let shared = SessionManager()
    let keychain = A0SimpleKeychain(service: "Auth0")
    private let authentication = Auth0.authentication()
    var credentialsManager: CredentialsManager!
    var userProfile: UserInfo?
    var credentials: Credentials?
    var code: String?
    var challenge: String?
    var verifier: String?
    var accessToken: String?
    
    
    private init () {
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        let context = LAContext()
       // if(context.biometryType == LABiometryType.faceID){
            self.credentialsManager.enableBiometrics(withTitle: "Use your face to authenticate")
       // } else if(context.biometryType == LABiometryType.touchID){
         //   self.credentialsManager.enableBiometrics(withTitle: "Touch to authenticate")
        //} else {
          //  print("No biometric authentication")
        //}
        
        // _ = self.authentication.logging(enabled: true) // API Logging
    }
    
    func renewAuth(_ callback: @escaping (Error?) -> ()) {
        // Check it is possible to return credentials before asking for Touch
        guard self.credentialsManager.hasValid() else {
            return callback(CredentialsManagerError.noCredentials)
        }
        self.credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                return callback(error)
            }
            self.credentials = credentials
            callback(nil)
        }
    }
    
    func retrieveProfile() {
//        guard let accessToken = self.keychain.string(forKey: "access_token") else {
//            return //SessionManagerError.noAccessToken
//        }
        Auth0
            .authentication()
            .userInfo(withAccessToken: (self.credentials?.accessToken)!)
            .start { result in
                switch(result) {
                case .success(let profile):
                    print("Successfully found profile = \(profile.email ?? "No email")")
                  
                    self.userProfile = profile
//return profile
                case .failure(let error):
                   print(error)
                 //  return nil
                }
        }
 
    }
    
    func login(userName:String,password:String) -> Bool{
        var status = false
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            Auth0.authentication().login(usernameOrEmail: userName, password: password, realm: "Username-Password-Authentication", audience: "https://assetar-stg.herokuapp.com/", scope: "openid profile").start{
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                    status = false
                    group.leave()
                   
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the hosted login page
                    print("Credentials: \(credentials)")
                    print(credentials.accessToken ?? "no access token");
                   
                    self.credentialsManager.store(credentials: credentials)
                    status = true
                    group.leave()
                   
 
                }
                
                }
            
        }
        group.wait()
        return status
    }
    
    func logout() {
        // Remove credentials from KeyChain
        self.keychain.clearAll()
        self.credentialsManager.clear()
    }
    
    
    /**LEGACY**/
    func store(credentials: Credentials,completionHandler: @escaping (Bool?) -> Void){
            // make an URL request
            // wait for results
            // check for errors and stuff
         
        self.credentials = credentials
        completionHandler(true)
        // Store credentials in KeyChain
       // self.credentialsManager.store(credentials: credentials)
    }
    func storeTokens(_ accessToken: String, idToken: String) {
        self.keychain.setString(accessToken, forKey: "access_token")
        self.keychain.setString(idToken, forKey: "id_token")
    }
    
    func retrieve(_ callback: @escaping (Error?) -> ()) {
        guard let accessToken = self.credentials?.accessToken else {
            return callback(CredentialsManagerError.noCredentials)
        }
        self.authentication.userInfo(withAccessToken: accessToken).start{
            result in
            switch(result){
            case .success(let profile):
                self.userProfile = profile
                callback(nil)
            case .failure(let error):
                callback(error)
                
            }
        }
    }
    
    
}
