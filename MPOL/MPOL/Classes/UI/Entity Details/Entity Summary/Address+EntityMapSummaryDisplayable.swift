//
//  Address+EntitySummaryDisplayable.swift
//  MPOL
//
//  Created by RUI WANG on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import MapKit

public struct AddressSummaryDisplayable: EntityMapSummaryDisplayable, AssociatedEntitySummaryDisplayable {
    public let address: Address

    public init(_ entity: MPOLKitEntity) {
        address = entity as! Address
    }

    public var category: String? {
        return address.source?.localizedBarTitle
    }

    public var title: StringSizable? {
        return AddressFormatter(style: .short).formattedString(from: address)
    }

    public var detail1: StringSizable? {
        let values: [String?] = [address.suburb?.capitalized, address.state?.uppercased(), address.postcode]
        return values.joined(separator: " ")
    }

    public var detail2: StringSizable? {
        return nil
    }

    public var association: String? {
        return address.formattedAssociationReasonsString()
    }

    public var borderColor: UIColor? {
        return address.associatedAlertLevel?.color
    }

    public var iconColor: UIColor? {
        return address.alertLevel?.color
    }

    public var badge: UInt {
        return 0
    }

    public var priority: Int {
        return address.alertLevel?.rawValue ?? -1
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let latitude = address.latitude, let longitude = address.longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let imageSize: CGSize
        switch size {
        case .small:
            imageSize = CGSize(width: 24, height: 24)
        case .medium:
            imageSize = CGSize(width: 48, height: 48)
        case .large:
            imageSize = CGSize(width: 72, height: 72)
        }

        if let image = AssetManager.shared.image(forKey: .entityLocation, ofSize: imageSize) {
            return ImageSizing(image: image, size: imageSize, contentMode: .center)
        }
        return nil
    }

    private func formattedAssociationReason() -> String? {
        guard let lastReason = address.associatedReasons?.last else { return nil }
        return lastReason.formattedReason()
    }
}
