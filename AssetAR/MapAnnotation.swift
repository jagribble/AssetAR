//
//  MapAnnotation.swift
//  AssetAR
//
//  Created by Jules on 21/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation:NSObject,MKAnnotation{
    var title:String? = ""
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(t: String,s:String,cord:CLLocationCoordinate2D){
        self.title = t
        self.subtitle = "\(s) meters"
        self.coordinate = cord
    }
    
}
