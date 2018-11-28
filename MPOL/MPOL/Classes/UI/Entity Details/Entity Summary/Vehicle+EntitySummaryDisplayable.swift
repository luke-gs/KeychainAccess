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

    public var title: StringSizable? {
        return (vehicle.registration ?? NSLocalizedString("Registration Unknown", comment: "")).sizing(withNumberOfLines: 0)
    }

    public var detail1: StringSizable? {
        return formattedVehicleDescription()?.sizing(withNumberOfLines: 0)
    }

    public var detail2: StringSizable? {
        return formattedVehicleColorBody()?.sizing(withNumberOfLines: 0)
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

    public var badge: UInt {
        return vehicle.actionCount
    }

    public var priority: Int {
        return vehicle.alertLevel?.rawValue ?? -1
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let vehicleType = VehicleType(optionalValue: vehicle.vehicleType)

        if let image = AssetManager.shared.image(forKey: vehicleType.imageKey, ofSize: size.imageSize) {
            return ImageSizing(image: image, size: size.imageSize, contentMode: .center)
        }

        return nil
    }

    private func formattedVehicleDescription() -> String? {

        let components = [vehicle.year, vehicle.make, vehicle.model].compactMap { $0 }
        if components.isEmpty == false {
            return components.joined(separator: " ")
        }

        return nil
    }

    private func formattedVehicleColorBody() -> String? {

        let components = [vehicle.primaryColor, vehicle.bodyType].compactMap { $0 }
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

    public var title: StringSizable? {
        return summaryDisplayable.title
    }

    public var detail1: StringSizable? {
        return summaryDisplayable.detail1
    }

    public var detail2: StringSizable? {
        return summaryDisplayable.detail2
    }

    public var borderColor: UIColor? {
        return summaryDisplayable.borderColor
    }

    public var iconColor: UIColor? {
        return summaryDisplayable.iconColor
    }

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

private enum VehicleType: String {
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

    var imageKey: AssetManager.ImageKey {
        switch self {
        case .car:
            return .entityCar
        case .motorcycle:
            return .entityMotorbike
        case .truck:
            return .entityTruck
        case .van:
            return .entityVan
        case .trailer:
            return .entityTrailer
        case .vessel:
            return .entityBoat
        }
    }
}

extension EntityThumbnailView.ThumbnailSize {
    public var imageSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 24, height: 24)
        case .medium:
            return CGSize(width: 48, height: 48)
        case .large:
            return CGSize(width: 72, height: 72)
        }
    }
}
