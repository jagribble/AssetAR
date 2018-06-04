//
//  Asset.swift
//  AssetAR
//
//  Created by Jules on 11/10/2017.
//  Copyright © 2017 Gribble. All rights reserved.
//

import Foundation

class Asset{
    var id:Int
    var assetName = ""
    var assetLocationX:Float
    var assetLocationZ:Float
    var orgainsationID:Int

    
    init(id: Int,name: String, x:Float, z:Float,oId:Int) {
        self.id = id
        self.assetName = name
        self.assetLocationX = x
        self.assetLocationZ = z
        self.orgainsationID = oId
    }
    
}
