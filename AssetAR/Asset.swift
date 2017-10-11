//
//  Asset.swift
//  AssetAR
//
//  Created by Jules on 11/10/2017.
//  Copyright © 2017 Gribble. All rights reserved.
//

import Foundation

class Asset{
    var assetName = ""
    var assetLocationX = 0.0
    var assetLocationY = 0.0
    
    init(name: String, x:Double, y:Double) {
        self.assetName = name
        self.assetLocationX = x
        self.assetLocationY = y
    }
    
}
