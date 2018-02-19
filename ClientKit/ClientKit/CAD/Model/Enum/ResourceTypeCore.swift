//
//  ResourceTypeCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Enum for resource types
public enum ResourceTypeCore: String, Codable, CADResourceUnitType {
    case bicycle        = "Bicycle"
    case dogSquad       = "DogSquad"
    case helicopter     = "Helicopter"
    case marineCraft    = "MarineCraft"
    case motorcycle     = "Motorcycle"
    case policeOfficer  = "PoliceOfficer"
    case vehicle        = "Vehicle"

    /// All cases, no particular order
    public static var allCases: [CADResourceUnitType] {
        return [
            ResourceTypeCore.bicycle,
            ResourceTypeCore.dogSquad,
            ResourceTypeCore.helicopter,
            ResourceTypeCore.marineCraft,
            ResourceTypeCore.motorcycle,
            ResourceTypeCore.policeOfficer,
            ResourceTypeCore.vehicle
        ]
    }

    /// The display title for the unit type
    public var title: String {
        switch self {
        case .bicycle:
            return NSLocalizedString("Bicycle", comment: "")
        case .dogSquad:
            return NSLocalizedString("Dog Squad", comment: "")
        case .helicopter:
            return NSLocalizedString("Helicopter", comment: "")
        case .marineCraft:
            return NSLocalizedString("Marine Craft", comment: "")
        case .motorcycle:
            return NSLocalizedString("Motorcycle", comment: "")
        case .policeOfficer:
            return NSLocalizedString("Patrol", comment: "")
        case .vehicle:
            return NSLocalizedString("Vehicle", comment: "")
        }
    }

    /// The icon image representing the unit type
    public var icon: UIImage? {
        return AssetManager.shared.image(forKey: imageKey)
    }

    /// The internal image key
    private var imageKey: AssetManager.ImageKey {
        switch self {
        case .bicycle:
            return .resourceBicycle
        case .dogSquad:
            return .resourceDog
        case .helicopter:
            return .resourceHelicopter
        case .marineCraft:
            return .resourceWater
        case .motorcycle:
            return .entityMotorbikeSmall
        case .policeOfficer:
            return .resourceBeat
        case .vehicle:
            return .resourceCar
        }
    }
}
