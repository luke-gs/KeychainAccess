//
//  ResourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Enum for resource types
public enum ResourceType: String, Codable {
    case vehicle    = "Vehicle"
    case dogSquad   = "DogSquad"

    var imageKey: AssetManager.ImageKey {
        switch self {
        case .vehicle:
            return .resourceCar
        case .dogSquad:
            return .resourceDog
        }
    }

    public func icon() -> UIImage? {
        return AssetManager.shared.image(forKey: imageKey)
    }
}
