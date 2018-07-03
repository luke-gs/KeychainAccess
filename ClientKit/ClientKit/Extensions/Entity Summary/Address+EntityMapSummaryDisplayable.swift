//
//  Address+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Created by RUI WANG on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import MapKit

public struct AddressSummaryDisplayable: EntityMapSummaryDisplayable {

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
        guard let coordinate = coordinate else {
            return nil
        }
        return "\(coordinate.latitude), \(coordinate.longitude)"
    }
    
    public var detail2: String? {
        return nil
    }
    
    public var borderColor: UIColor? {
        return address.associatedAlertLevel?.color
    }

    public var iconColor: UIColor? {
        // Return .black because the current implementation use `tintColor`.
        // nil means use system's.
        return address.alertLevel?.color ?? .black
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
        let imageName: String

        switch size {
        case .small:
            imageName = "iconEntityLocation"
        case .medium:
            imageName = "iconEntityLocation48"
        case .large:
            imageName = "iconEntityLocation96"
        }

        if let image = UIImage(named: imageName, in: .mpolKit, compatibleWith: nil) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }

        return nil
    }
}
