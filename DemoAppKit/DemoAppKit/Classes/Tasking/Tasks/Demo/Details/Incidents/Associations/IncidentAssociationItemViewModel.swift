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
        case person(initials: String, thumbnailUrl: URL?)
        case vehicle
    }
    
    public required init(_ entity: MPOLKitEntity) {
        MPLUnimplemented()
    }
    
    public init(association: CADIncidentAssociationType, category: String?, entityType: EntityType, title: String?, detail1: String?, detail2: String?, borderColor: UIColor?, iconColor: UIColor? = nil, badge: UInt) {
        self.association = association
        self.category = category
        self.entityType = entityType
        self.title = title
        self.iconColor = iconColor
        self.detail1 = detail1
        self.detail2 = detail2
        self.borderColor = borderColor
        self.badge = badge
    }
    
    public var association: CADIncidentAssociationType

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
        case let .person(initials, thumbnailUrl):
            return CADPersonImageSizing(initials: initials, thumbnailUrl: thumbnailUrl)
        case .vehicle:
            let imageKey: AssetManager.ImageKey
            
            switch size {
            case .small:
                imageKey = .entityCarSmall
            case .medium:
                imageKey = .entityCarMedium
            case .large:
                imageKey = .entityCarLarge
            }

            thumbnailImage = AssetManager.shared.image(forKey: imageKey)
            contentMode = .center
        }
        
        if let thumbnailImage = thumbnailImage {
            return ImageSizing(image: thumbnailImage, size: thumbnailImage.size, contentMode: contentMode)
        }
        
        return nil
    }

}

/// Async Image Loading class for loading person thumbnails
public class CADPersonImageSizing: AsynchronousImageSizing {

    public let initials: String
    public let thumbnailUrl: URL?

    public init(initials: String, thumbnailUrl: URL?) {
        self.initials = initials
        self.thumbnailUrl = thumbnailUrl

        let image = UIImage.thumbnail(withInitials: initials)
        let thumbnailSizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFill)
        super.init(placeholderImage: thumbnailSizing)
    }

    public override func loadImage(completion: @escaping (ImageSizable) -> ()) {

        // Code to retrieve image goes here
        if let thumbnailUrl = thumbnailUrl {
            _ = ImageDownloader.default.fetch(for: thumbnailUrl).done { image -> Void in
                let sizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFit)
                completion(sizing)
            }.cauterize()
        }
    }
}
