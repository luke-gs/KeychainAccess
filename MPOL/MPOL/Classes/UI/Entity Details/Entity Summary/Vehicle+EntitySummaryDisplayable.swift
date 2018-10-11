//
//  Vehicle+EntitySummaryDisplayable.swift
//  MPOL
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct VehicleSummaryDisplayable: AssociatedEntitySummaryDisplayable {

    private var vehicle: Vehicle

    public init(_ entity: MPOLKitEntity) {
        vehicle = entity as! Vehicle
    }

    public var category: String? {
        return vehicle.source?.localizedBarTitle
    }
    
    public var title: String? {
        return vehicle.registration ?? NSLocalizedString("Registration Unknown", comment: "")
    }
    
    public var detail1: String? {
        return formattedYOMMakeModel()
    }
    
    public var detail2: String? {
        return vehicle.bodyType
    }
    
    public var association: String? {
        return vehicle.formattedAssociationReasonsString()
    }
    
    public var borderColor: UIColor? {
        return vehicle.associatedAlertLevel?.color
    }

    public var iconColor: UIColor? {
        return vehicle.alertLevel?.color
    }
    
    public var subtitleColor: UIColor? = nil
    
    public var badge: UInt {
        return vehicle.actionCount
    }

    public var priority: Int {
        return vehicle.alertLevel?.rawValue ?? -1
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let vehicleType = VehicleType(optionalValue: vehicle.vehicleType)

        let vehicleString: String = vehicleType.imageAssetString
        let sizeString: String = size.imageSizeString

        let imageName = vehicleString + sizeString
        let imageKey = AssetManager.ImageKey(imageName)

        if let image = AssetManager.shared.image(forKey: imageKey) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }

        return nil
    }
    
    private func formattedYOMMakeModel() -> String? {
        
        let components = [vehicle.year, vehicle.make, vehicle.model].compactMap { $0 }
        if components.isEmpty == false {
            return components.joined(separator: " ")
        }
        
        return nil
    }
    
}


public struct VehicleDetailsDisplayable: EntitySummaryDisplayable {

    private var vehicle: Vehicle
    private var summaryDisplayable: VehicleSummaryDisplayable

    public init(_ entity: MPOLKitEntity) {
        vehicle = entity as! Vehicle
        summaryDisplayable = VehicleSummaryDisplayable(vehicle)
    }

    public var category: String? {
        return vehicle.source?.localizedBadgeTitle
    }

    public var title: String? {
        return summaryDisplayable.title
    }

    public var detail1: String? {
        return summaryDisplayable.detail1
    }

    public var detail2: String? {
        return summaryDisplayable.detail2
    }

    public var borderColor: UIColor? {
        return summaryDisplayable.borderColor
    }

    public var iconColor: UIColor? {
        return summaryDisplayable.iconColor
    }
    
    public var subtitleColor: UIColor? = nil

    public var badge: UInt {
        return summaryDisplayable.badge
    }

    public var priority: Int {
        return summaryDisplayable.priority
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return summaryDisplayable.thumbnail(ofSize: size)
    }
}

fileprivate enum VehicleType: String {
    case car
    case motorcycle
    case truck
    case van
    case trailer
    case vessel

    init(optionalValue: String?, fallbackValue: VehicleType = .car) {
        guard let value = optionalValue else {
            self = fallbackValue
            return
        }

        self = VehicleType(rawValue: value.lowercased()) ?? fallbackValue
    }

    var imageAssetString: String {
        switch self {
        case .car:
            return "iconEntityAutomotiveCar"
        case .motorcycle:
            return "iconEntityVehicleMotorcycle"
        case .truck:
            return "iconEntityVehicleTruck"
        case .van:
            return "iconEntityVehicleVan"
        case .trailer:
            return"iconEntityAutomotiveTrailer"
        case .vessel:
            return "iconEntityAutomotiveWater"
        }
    }
}

extension EntityThumbnailView.ThumbnailSize {
    public var imageSizeString: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        }
    }
}
