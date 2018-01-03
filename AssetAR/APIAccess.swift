//
//  APIAccess.swift
//  AssetAR
//
//  Created by Jules on 03/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import Foundation
import CommonCrypto
import PromiseKit
import Auth0

func codeVerifier(){
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    let verifier = Data(bytes: buffer).base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "")
        .replacingOccurrences(of: "=", with: "")
        .trimmingCharacters(in: .whitespaces)
    // You need to import CommonCrypto
    guard let data = verifier.data(using: .utf8) else {
        return;
    }
    buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
    }
    let hash = Data(bytes: buffer)
    let challenge = hash.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "")
        .replacingOccurrences(of: "=", with: "")
        .trimmingCharacters(in: .whitespaces)
    
//    var state = ""
    var auth0 = Auth0.authentication(clientId: "2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z", domain: "app79553870.auth0.com")
    auth0.logging(enabled: true)
    auth0.tokenExchange(withCode: SessionManager.shared.code!, codeVerifier: SessionManager.shared.verifier!, redirectURI: "Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback").start{
        switch $0 {
        case .failure(let error):
            // Handle the error
            print("Error: \(error)")
        case .success(let response):
            // Do something with credentials e.g.: save them.
            // Auth0 will automatically dismiss the hosted login page
            print("---------------")
            print(response.accessToken)
            SessionManager.shared.accessToken? = response.accessToken!
            
            print("---------------")
        }
    }
//
//    Auth0.webAuth().audience("https://app79553870.auth0.com/authorize").scope("profile").responseType([ResponseType.code]).parameters(["code_challenge_method":"S256"]).parameters(["redirect_uri":"Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback"]).parameters(["code_challenge":"\(challenge)"]).parameters(["client_id":"2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z"]).start{
//        switch $0 {
//            case .failure(let error):
//                // Handle the error
//                print("Error: \(error)")
//            case .success(let response):
//                // Do something with credentials e.g.: save them.
//                // Auth0 will automatically dismiss the hosted login page
//                print("---------------")
//                print(response)
//                print("---------------")
//            }
//    }
    
//    Auth0.webAuth(clientId: "2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z", domain: "app79553870.auth0.com")
//        .audience("//assetar-stg.herokuapp.com")
//        .start{
//            switch $0 {
//            case .failure(let error):
//                // Handle the error
//                print("Error: \(error)")
//            case .success(let response):
//                // Do something with credentials e.g.: save them.
//                // Auth0 will automatically dismiss the hosted login page
//                print("---------------")
//                print(response)
//                print("---------------")
//            }
//    }
    
    
    // Configure your request here (method, body, etc)
//    let session = URLSession.shared
//    let url = URL(string: "https://app79553870.auth0.com/authorize?audience=https://assetar-stg.herokuapp.com/&scope=profile&response_type=code&client_id=2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z&code_challenge=\(challenge)&code_challenge_method=S256&redirect_uri=Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback")
    
  //  print("URL = \(url?.absoluteString)")
//    let request = URLRequest(url: url!)
//    URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//           // print(response ?? "")
//        let responseData = String(data: data!, encoding: String.Encoding.utf8)
//            //print("body = \(responseData)")
//            var query = response?.url?.query?.components(separatedBy: "&")
//            state = query![(query?.count)!-1].components(separatedBy: "=")[1]
//
//
//
//            print("----------------------------------")
            // second request
    
    
//
//            let headers = ["content-type": "application/json"]
//
//            let postData = NSData(data: "{'grant_type':'authorization_code','client_id': '2Aqfrn4k24VEvwKcu0WmRlMgj6SkIU6Z','code_verifier': '\(SessionManager.shared.verifier)','code': '\(SessionManager.shared.code )','redirect_uri': 'Gribble.AssetAR://app79553870.auth0.com/ios/Gribble.AssetAR/callback',}".data(using: String.Encoding.utf8)!)
//
//            print("post Data = \(postData)")
//            let url2 = URL(string: "https://app79553870.auth0.com/oauth/token")
//            var request2 = URLRequest(url: url2!)
//
//
//            request2.httpMethod = "POST"
//            request2.allHTTPHeaderFields = headers
//            request2.httpBody = postData as Data
//            request2.cachePolicy = .useProtocolCachePolicy
//            request2.timeoutInterval = 10.0
//
//            URLSession.shared.dataTask(with: request2, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//                if (error != nil) {
//                    print(error ?? "")
//                } else {
//                    let httpResponse = response
//                    print(httpResponse ?? "")
//                    guard let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
//                        print("Can not convert data to JSON object")
//                        return
//                    }
//                    print(json)
//                }
//
//            }).resume()
//
    
//        }).resume()
    
   
    
    

}

