//
//  LookupAddress.swift
//  MPOLKit
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation
import Unbox

public struct LookupAddress: Unboxable {
    public let id: String
    public let fullAddress: String

    public let coordinate: CLLocationCoordinate2D
    public let isAlias: Bool

    public init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: CodingKeys.id.rawValue)
        fullAddress = try unboxer.unbox(key: CodingKeys.fullAddress.rawValue)

        let latitude = try unboxer.unbox(key: CodingKeys.latitude.rawValue) as CLLocationDegrees
        let longitude = try unboxer.unbox(key: CodingKeys.longitude.rawValue) as CLLocationDegrees
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        isAlias = try unboxer.unbox(key: CodingKeys.isAlias.rawValue)
    }

    private enum CodingKeys: String {
        case id = "id"
        case fullAddress = "fullAddress"
        case latitude = "latitude"
        case longitude = "longitude"
        case isAlias = "isAlias"
    }
}
