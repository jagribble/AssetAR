//
//  DataPoint.swift
//  AssetAR
//
//  Created by Jules on 11/04/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import Foundation

class DataPoint {
    var timestamp:String
    var data:String
    var dataTypeID:String
    
    init(t:String,d:String,dTID:String){
        self.timestamp = t
        self.data = d
        self.dataTypeID = dTID
    }
}
