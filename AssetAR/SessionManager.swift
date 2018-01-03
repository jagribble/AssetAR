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
        // _ = self.authentication.logging(enabled: true) // API Logging
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
    
    func retrieveProfile(_ callback: @escaping (Error?) -> ()) {
        guard let accessToken = self.keychain.string(forKey: "access_token") else {
            return callback(SessionManagerError.noAccessToken)
        }
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch(result) {
                case .success(let profile):
                    self.userProfile = profile
                    callback(nil)
                case .failure(let error):
                    callback(error)
                }
        }
    }
    
    func logout() {
        // Remove credentials from KeyChain
        self.keychain.clearAll()
    }
    
    func store(credentials: Credentials) -> Bool {
        self.credentials = credentials
        // Store credentials in KeyChain
        return self.credentialsManager.store(credentials: credentials)
    }
    
    
}
