//
//  LocationExtention.swift
//  AssetAR
//
//  Created by Jules on 17/02/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

// Code Modifed from https://github.com/ProjectDent/ARKit-CoreLocation/blob/master/ARKit%2BCoreLocation/Source/CLLocation%2BExtensions.swift

import Foundation
import CoreLocation

public extension CLLocation{
    
    public func translation(toLocation location: CLLocation) -> LocationTranslation {
        let inbetweenLocation = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let distanceLatitude = location.distance(from: inbetweenLocation)
        
        let latitudeTranslation: Double
        
        if location.coordinate.latitude > inbetweenLocation.coordinate.latitude {
            latitudeTranslation = distanceLatitude
        } else {
            latitudeTranslation = 0 - distanceLatitude
        }
        
        let distanceLongitude = self.distance(from: inbetweenLocation)
        
        let longitudeTranslation: Double
        
        if self.coordinate.longitude > inbetweenLocation.coordinate.longitude {
            longitudeTranslation = 0 - distanceLongitude
        } else {
            longitudeTranslation = distanceLongitude
        }
        
        let altitudeTranslation = location.altitude - self.altitude
        
        return LocationTranslation(
            latitudeTranslation: -latitudeTranslation,
            longitudeTranslation: longitudeTranslation,
            altitudeTranslation: altitudeTranslation)
    }
}

///Translation in meters between 2 locations
public struct LocationTranslation {
    public var latitudeTranslation: Double
    public var longitudeTranslation: Double
    public var altitudeTranslation: Double
    
    public init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}
