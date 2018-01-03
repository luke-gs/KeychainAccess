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
        highlightStyle     = .fade(FadeStyle())
        
        if let thumbnailInfo = entitySummary.thumbnail(ofSize: style == .hero ? .large : .medium) {
            self.thumbnailView.imageView.setImage(with: thumbnailInfo)
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
        subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: ThemeConstants.dividerSeparator)
        
        borderColor        = entitySummary.borderColor
        actionCount        = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade(FadeStyle())
        
        accessoryView      = accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)

        if let thumbnailInfo = entitySummary.thumbnail(ofSize: .small) {
            self.thumbnailView.imageView.setImage(with: thumbnailInfo)
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entitySummary.borderColor
        thumbnailView.tintColor = entitySummary.iconColor
    }
}

extension EntityListCollectionViewCell: EntityMapSummaryDecoratable {
    public func decorate(with entitySummary: EntityMapSummaryDisplayable) {
        titleLabel.text    = entitySummary.title
        subtitleLabel.text = entitySummary.detail1
        borderColor        = entitySummary.iconColor
        actionCount        = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade(FadeStyle())
        separatorStyle     = .none

        accessoryView      = accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)

        if let thumbnailInfo = entitySummary.thumbnail(ofSize: .small) {
            self.thumbnailView.imageView.setImage(with: thumbnailInfo)
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entitySummary.borderColor
    }
}
