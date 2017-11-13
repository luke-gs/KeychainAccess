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
        return address.source?.localizedBadgeTitle
    }
    
    public var title: String? {
        return shortFormattedAddress()
    }
    
    public var detail1: String? {
        return type(of: address).serverTypeRepresentation
    }
    
    public var detail2: String? {
        return address.formatted()
    }
    
    public var borderColor: UIColor? {
        return address.alertLevel?.color
    }

    public var iconColor: UIColor? {
        return nil
    }
    
    public var badge: UInt {
        return 0
    }

    public var streetViewButtonTitle: String? {
        return "Street View"
    }

    public var walkingLabelPlaceholder: String? {
        return "Calculating"
    }

    public var automobileLabelPlaceholder: String? {
        return "Calculating"
    }

    public func mapAnnotationThumbnail() -> UIImage? {
        
        // TODO: Check alertLevel to assign different image
        if let image = AssetManager.shared.image(forKey: .location) {
            return image
        }
        return nil
    }
    
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let latitude = address.latitude, let longitude = address.longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        if let image = AssetManager.shared.image(forKey: .location) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }
        return nil
    }
    
    private func shortFormattedAddress() -> String? {
        var lines: [[String]] = []
        var line: [String] = []
        
        if let unitNumber = address.unit?.ifNotEmpty() {
            line.append("Unit \(unitNumber)")
        }
        
        if let floor = address.floor?.ifNotEmpty() {
            line.append("Floor \(floor)")
        }
        
        if line.isEmpty == false {
            lines.append(line)
            line.removeAll()
        }
        
        if let streetNumber = address.streetNumberFirst?.ifNotEmpty() {
            line.append(streetNumber)
        }
        
        if let streetName = address.streetName?.ifNotEmpty() {
            line.append(streetName)
        }
        
        if let streetType = address.streetType?.ifNotEmpty() {
            line.append(streetType)
        }
        
        if let streetDirectional = address.streetDirectional?.ifNotEmpty() {
            line.append(streetDirectional)
        }
        
        if line.isEmpty == false {
            if lines.isEmpty == false && line.joined(separator: " ") == address.commonName {
                _ = lines.remove(at: 0)
            }
            lines.append(line)
            line.removeAll()
        }
        
        return lines.flatMap { $0.isEmpty == false ? $0.joined(separator: " ") : nil }.joined(separator: " ")
    }
}
