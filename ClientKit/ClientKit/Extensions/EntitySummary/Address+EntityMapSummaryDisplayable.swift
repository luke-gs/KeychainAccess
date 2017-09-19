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

extension Address: EntityMapSummaryDisplayable {
    
    public var category: String? {
        return source?.localizedBadgeTitle
    }
    
    public var title: String? {
        return shortFormattedAddress()
    }
    
    public var detail1: String? {
        return type(of: self).serverTypeRepresentation
    }
    
    public var detail2: String? {
        return formatted()
    }
    
    public var alertColor: UIColor? {
        return alertLevel?.color
    }
    
    public var badge: UInt {
        return 0
    }
    
    public func mapAnnotationThumbnail() -> UIImage? {
        
        // TODO: Check alertLevel to assign different image
        if let image = AssetManager.shared.image(forKey: .location) {
            return image
        }
        return nil
    }
    
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        if let image = AssetManager.shared.image(forKey: .location) {
            return (image, .center)
        }
        return nil
    }
    

    
    private func shortFormattedAddress() -> String? {
        var lines: [[String]] = []
        var line: [String] = []
        
        if let unitNumber = self.unit?.ifNotEmpty() {
            line.append("Unit \(unitNumber)")
        }
        
        if let floor = self.floor?.ifNotEmpty() {
            line.append("Floor \(floor)")
        }
        
        if line.isEmpty == false {
            lines.append(line)
            line.removeAll()
        }
        
        if let streetNumber = self.streetNumberFirst?.ifNotEmpty() {
            line.append(streetNumber)
        }
        
        if let streetName = self.streetName?.ifNotEmpty() {
            line.append(streetName)
        }
        
        if let streetType = self.streetType?.ifNotEmpty() {
            line.append(streetType)
        }
        
        if let streetDirectional = self.streetDirectional?.ifNotEmpty() {
            line.append(streetDirectional)
        }
        
        if line.isEmpty == false {
            if lines.isEmpty == false && line.joined(separator: " ") == commonName {
                _ = lines.remove(at: 0)
            }
            lines.append(line)
            line.removeAll()
        }
        
        return lines.flatMap { $0.isEmpty == false ? $0.joined(separator: " ") : nil }.joined(separator: " ")
    }
}
