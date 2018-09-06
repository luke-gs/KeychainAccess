//
//  Organisation+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct OrganisationSummaryDisplayable: EntityMapSummaryDisplayable, AssociatedEntitySummaryDisplayable {
    
    private var organisation: Organisation
    
    public init(_ entity: MPOLKitEntity) {
        organisation = entity as! Organisation
    }
    
    public var category: String? {
        return organisation.source?.localizedBarTitle
    }
    
    public var title: String? {
        return organisation.summary
    }
    
    public var detail1: String? {
        return organisation.type
    }
    
    public var detail2: String? {
        return organisation.locations?.first?.fullAddress
    }
    
    public var association: String? {
        return organisation.formattedAssociationReasonsString()
    }
    
    public var borderColor: UIColor? {
        return organisation.associatedAlertLevel?.color
    }
    
    public var iconColor: UIColor? {
        return organisation.alertLevel?.color
    }
    
    public var badge: UInt {
        return organisation.actionCount
    }
    
    public var priority: Int {
        return organisation.alertLevel?.rawValue ?? -1
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let imageKey: AssetManager.ImageKey
        
        switch size {
        case .small:
            imageKey = .entityOrganisationSmall
        case .medium:
            imageKey = .entityOrganisationMedium
        case .large:
            imageKey = .entityOrganisationLarge
        }
        
        if let image = AssetManager.shared.image(forKey: imageKey) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }
        
        return nil
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let location = organisation.locations?.first,
            let lat = location.latitude,
            let lon = location.longitude else { return nil }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}


public struct OrganisationDetailsDisplayable: EntitySummaryDisplayable {
    
    private var organisation: Organisation
    private var summaryDisplayable: OrganisationSummaryDisplayable
    
    public init(_ entity: MPOLKitEntity) {
        organisation = entity as! Organisation
        summaryDisplayable = OrganisationSummaryDisplayable(organisation)
    }
    
    public var category: String? {
        return organisation.source?.localizedBadgeTitle
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
