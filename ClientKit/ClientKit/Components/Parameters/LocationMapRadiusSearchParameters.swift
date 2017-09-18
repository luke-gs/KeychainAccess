//
//  LocationMapSearchParameters.swift
//  ClientKit
//
//  Created by RUI WANG on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap

public class LocationMapRadiusSearchParameters: EntitySearchRequest<Address> {

    public init(latitude: Double, longitude: Double, radius: Double, maxResults: Int = 10) {
        let parameterisable = SearchParameters(latitude: latitude, longitude: longitude, radius: radius, maxResults: maxResults)
        
        super.init(parameters: parameterisable.parameters)
    }

    private struct SearchParameters: Parameterisable {
        
        public let latitude: Double
        public let longitude: Double
        public let radius: Double
        public let maxResults: Int
        
        public init(latitude: Double, longitude: Double, radius: Double, maxResults: Int) {
            self.latitude = latitude
            self.longitude = longitude
            self.radius = radius
            self.maxResults = maxResults
        }
        
        public var parameters: [String : Any] {
            return try! wrap(self)
        }
    }
}


public class LocationMapBoundingBoxSearchParameters: EntitySearchRequest<Address> {
    
    public init(northWestLatitude: Double, northWestLongitude: Double, southEastLatitude: Double, southEastLongitude: Double, maxResults: Int = 10) {
        let parameterisable = SearchParameters(northWestLatitude: northWestLatitude, northWestLongitude: northWestLongitude, southEastLatitude: southEastLatitude, southEastLongitude: southEastLongitude, maxResults: maxResults)
        
        super.init(parameters: parameterisable.parameters)
    }
    
    private struct SearchParameters: Parameterisable {
        
        public let northWestLatitude: Double
        public let northWestLongitude: Double
        public let southEastLatitude: Double
        public let southEastLongitude: Double
        public let maxResults: Int
        
        public init(northWestLatitude: Double, northWestLongitude: Double, southEastLatitude: Double, southEastLongitude: Double, maxResults: Int) {
            self.northWestLatitude = northWestLatitude
            self.northWestLongitude = northWestLongitude
            self.southEastLatitude = southEastLatitude
            self.southEastLongitude = southEastLongitude
            self.maxResults = maxResults
        }
        
        public var parameters: [String : Any] {
            return try! wrap(self)
        }
    }
}
