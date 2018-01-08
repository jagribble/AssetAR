//
//  UIViewControllerExtention.swift
//  AssetAR
//
//  Created by Jules on 08/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//
// Code adapted from https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
