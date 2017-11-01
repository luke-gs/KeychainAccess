//
//  EntitySummaryDecorator.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


extension EntityCollectionViewCell: EntitySummaryDecoratable {
    public func decorate(with entitySummary: EntitySummaryDisplayable) {
        titleLabel.text    = entitySummary.title
        subtitleLabel.text = entitySummary.detail1
        detailLabel.text   = entitySummary.detail2
        borderColor        = entitySummary.borderColor
        badgeCount         = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade
        
        if let thumbnailInfo = entitySummary.thumbnail(ofSize: style == .hero ? .large : .medium) {

            thumbnailInfo.loadImage(completion: { sizable in
                let image = sizable.sizing()
                self.thumbnailView.imageView.contentMode = image.contentMode ?? .scaleToFill
                self.thumbnailView.imageView.image = image.image
            })

        } else {
            thumbnailView.imageView.image = nil
        }
        thumbnailView.tintColor = entitySummary.iconColor
        thumbnailView.borderColor = entitySummary.borderColor
    }
}


extension EntityListCollectionViewCell: EntitySummaryDecoratable {
    public func decorate(with entitySummary: EntitySummaryDisplayable) {
        let subtitleComponents = [entitySummary.detail1, entitySummary.detail2].flatMap({$0})
        
        titleLabel.text    = entitySummary.title
        subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        
        borderColor        = entitySummary.borderColor
        actionCount        = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade
        
        accessoryView      = accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)

        if let thumbnailInfo = entitySummary.thumbnail(ofSize: .small) {
            thumbnailInfo.loadImage(completion: { sizable in
                let image = sizable.sizing()
                self.thumbnailView.imageView.contentMode = image.contentMode ?? .scaleToFill
                self.thumbnailView.imageView.image = image.image
            })
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entitySummary.borderColor
        thumbnailView.tintColor = entitySummary.iconColor
    }
}
