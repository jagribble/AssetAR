//
//  HomeViewController.swift
//  AssetAR
//
//  Created by Jules on 16/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit

class HomeViewController:UIViewController{
    
    @IBAction func logout(_ sender: Any) {
        SessionManager.shared.logout()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as? LoginViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
}
