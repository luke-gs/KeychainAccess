//
//  Address+EntitySummaryDisplayable.swift
//  ClientKit
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
    
    public var title: String? {
        return AddressFormatter(style: .short).formattedString(from: address)
    }
    
    public var detail1: String? {
        let values: [String?] = [address.suburb?.capitalized, address.state?.uppercased(), address.postcode]
        return values.joined(separator: " ")
    }
    
    public var detail2: String? {
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
        let imageKey: AssetManager.ImageKey

        switch size {
        case .small:
            imageKey = .entityLocationSmall
        case .medium:
            imageKey = .entityLocationMedium
        case .large:
            imageKey = .entityLocationLarge
        }

        if let image = AssetManager.shared.image(forKey: imageKey) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }
        return nil
    }
    
    private func formattedAssociationReason() -> String? {
        guard let lastReason = address.associatedReasons?.last else { return nil }
        return lastReason.formattedReason()
    }
}
