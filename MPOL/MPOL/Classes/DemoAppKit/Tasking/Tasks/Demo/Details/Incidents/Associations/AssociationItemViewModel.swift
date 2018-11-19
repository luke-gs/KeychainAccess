//
//  IncidentAssociationItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
public class AssociationItemViewModel: EntitySummaryDisplayable {

    public enum EntityType {
        case person(initials: String, thumbnailUrl: URL?)
        case vehicle
    }

    public required init(_ entity: MPOLKitEntity) {
        MPLUnimplemented()
    }

    public init(association: CADAssociationType, category: String?, entityType: EntityType, title: String?, detail1: String?, detail2: String?, borderColor: UIColor?, iconColor: UIColor? = nil, badge: UInt) {
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

    public var association: CADAssociationType

    public var entityType: EntityType

    public var category: String?

    public var title: StringSizable?

    public var detail1: StringSizable?

    public var detail2: StringSizable?

    public var borderColor: UIColor?

    public var iconColor: UIColor?

    public var badge: UInt

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let thumbnailImage: UIImage?
        let contentMode: UIView.ContentMode
        let imageSize: CGSize

        switch entityType {
        case let .person(initials, thumbnailUrl):
            return CADPersonImageSizing(initials: initials, thumbnailUrl: thumbnailUrl)
        case .vehicle:
            switch size {
            case .small:
                imageSize = CGSize(width: 24, height: 24)
            case .medium:
                imageSize = CGSize(width: 48, height: 48)
            case .large:
                imageSize = CGSize(width: 72, height: 72)
            }

            thumbnailImage = AssetManager.shared.image(forKey: .entityCar, ofSize: imageSize)
            contentMode = .center
        }

        if let thumbnailImage = thumbnailImage {
            return ImageSizing(image: thumbnailImage, size: imageSize, contentMode: contentMode)
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

    public override func loadImage(completion: @escaping (ImageSizable) -> Void) {

        // Code to retrieve image goes here
        if let thumbnailUrl = thumbnailUrl {
            _ = ImageDownloader.default.fetch(for: thumbnailUrl).done { image -> Void in
                let sizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFit)
                completion(sizing)
            }.cauterize()
        }
    }
}
