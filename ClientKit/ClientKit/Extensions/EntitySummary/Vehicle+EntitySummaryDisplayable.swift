//
//  Vehicle+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public struct VehicleSummaryDisplayable: EntitySummaryDisplayable {

    private var vehicle: Vehicle

    public init(_ entity: MPOLKitEntity) {
        vehicle = entity as! Vehicle
    }

    public var category: String? {
        return vehicle.source?.localizedBadgeTitle
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
    
    public var borderColor: UIColor? {
        return vehicle.alertLevel?.color
    }

    public var iconColor: UIColor? {
        return nil
    }
    
    public var badge: UInt {
        return vehicle.actionCount
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> AsynchronousImageSizing? {
        let imageName: String

        switch size {
        case .small:
            imageName = "iconEntityAutomotiveCar"
        case .medium:
            imageName = "iconEntityAutomotiveCar48"
        case .large:
            imageName = "iconEntityAutomotiveCar96"
        }

        if let image = UIImage(named: imageName, in: .mpolKit, compatibleWith: nil) {
            return AsynchronousImageSizing(placeholderImage: ImageSizing(image: image, size: image.size, contentMode: .center))
        }

        return nil
    }
    
    private func formattedYOMMakeModel() -> String? {
        
        let components = [vehicle.year, vehicle.make, vehicle.model].flatMap { $0 }
        if components.isEmpty == false {
            return components.joined(separator: " ")
        }
        
        return nil
    }
    
}

