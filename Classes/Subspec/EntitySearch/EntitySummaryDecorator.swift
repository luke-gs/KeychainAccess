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
        let subtitleComponents = [entitySummary.detail1, entitySummary.detail2].compactMap({$0})
        
        titleLabel.text    = entitySummary.title
        subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: ThemeConstants.dividerSeparator)
        
        borderColor        = entitySummary.borderColor
        actionCount        = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade
        
        accessoryView      = accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)

        if let thumbnailInfo = entitySummary.thumbnail(ofSize: .small) {
            self.thumbnailView.imageView.setImage(with: thumbnailInfo)

            thumbnailInfo.loadImage(completion: { [weak self] (imageSizable) in
                let sizing = imageSizable.sizing()
                self?.thumbnailView.imageView.image = sizing.image
                self?.thumbnailView.imageView.contentMode = sizing.contentMode ?? .center
            })
        } else {
            thumbnailView.imageView.image = nil
        }
        
        
        thumbnailView.borderColor = entitySummary.borderColor
        thumbnailView.tintColor = entitySummary.iconColor
        
        sourceLabel.backgroundColor = .clear
        sourceLabel.borderColor = ThemeManager.shared.theme(for: .current).color(forKey: Theme.ColorKey.secondaryText)
        sourceLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: Theme.ColorKey.secondaryText)
    }
}
