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
        alertColor         = entitySummary.alertColor
        badgeCount         = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade
        
        if let thumbnailInfo = entitySummary.thumbnail(ofSize: style == .hero ? .large : .medium) {
            thumbnailView.imageView.contentMode = thumbnailInfo.mode
            thumbnailView.imageView.image = thumbnailInfo.image
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entitySummary.alertColor
    }
}


extension EntityListCollectionViewCell: EntitySummaryDecoratable {
    public func decorate(with entitySummary: EntitySummaryDisplayable) {
        let subtitleComponents = [entitySummary.detail1, entitySummary.detail2].flatMap({$0})
        
        titleLabel.text    = entitySummary.title
        subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        
        alertColor         = entitySummary.alertColor
        actionCount        = entitySummary.badge
        sourceLabel.text   = entitySummary.category
        highlightStyle     = .fade
        
        accessoryView      = accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        if let thumbnailInfo = entitySummary.thumbnail(ofSize: .small) {
            thumbnailView.imageView.contentMode = thumbnailInfo.mode
            thumbnailView.imageView.image = thumbnailInfo.image
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entitySummary.alertColor
    }
}
