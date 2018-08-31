//
//  Organisation+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct OrganisationSummaryDisplayable: AssociatedEntitySummaryDisplayable {
    
    private var organisation: Organisation
    
    public init(_ entity: MPOLKitEntity) {
        organisation = entity as! Organisation
    }
    
    public var category: String? {
        return organisation.source?.localizedBarTitle
    }
    
    public var title: String? {
        return organisation.name
    }
    
    public var detail1: String? {
        return organisation.type
    }
    
    public var detail2: String? {
        return nil
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
        let imageName: String
        
        switch size {
        case .small:
            imageName = "iconEntityBuildingFilled"
        case .medium:
            imageName = "iconEntityBuilding48Filled"
        case .large:
            imageName = "iconEntityBuilding96Filled"
        }
        
        if let image = UIImage(named: imageName, in: .patternKit, compatibleWith: nil) {
            return ImageSizing(image: image, size: image.size, contentMode: .center)
        }
        
        return nil
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
