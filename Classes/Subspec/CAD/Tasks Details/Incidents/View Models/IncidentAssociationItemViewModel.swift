//
//  IncidentAssociationItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationItemViewModel: EntitySummaryDisplayable {
    
    public enum EntityType {
        case person(initials: String)
        case vehicle
    }
    
    public required init(_ entity: MPOLKitEntity) {
        MPLUnimplemented()
    }
    
    public init(category: String?, entityType: EntityType, title: String?, detail1: String?, detail2: String?, borderColor: UIColor?, iconColor: UIColor? = nil, badge: UInt) {
        self.category = category
        self.entityType = entityType
        self.title = title
        self.iconColor = iconColor
        self.detail1 = detail1
        self.detail2 = detail2
        self.borderColor = borderColor
        self.badge = badge
    }
    
    public var entityType: EntityType

    public var category: String?
    
    public var title: String?
    
    public var detail1: String?
    
    public var detail2: String?
    
    public var borderColor: UIColor?
    
    public var iconColor: UIColor?

    public var badge: UInt
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let thumbnailImage: UIImage?
        let contentMode: UIViewContentMode
        switch entityType {
        case let .person(initials):
            thumbnailImage = UIImage.thumbnail(withInitials: initials)
            contentMode = .scaleAspectFill
        case .vehicle:
            thumbnailImage = AssetManager.shared.image(forKey: .entityCar)
            contentMode = .center
        }
        
        if let thumbnailImage = thumbnailImage {
            return ImageSizing(image: thumbnailImage, size: thumbnailImage.size, contentMode: contentMode)
        }
        
        return nil
    }

}
