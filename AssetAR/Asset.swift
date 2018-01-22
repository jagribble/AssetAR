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
    var assetLocationX:Float
    var assetLocationZ:Float
    
    init(name: String, x:Float, z:Float) {
        self.assetName = name
        self.assetLocationX = x
        self.assetLocationZ = z
    }
    
}
