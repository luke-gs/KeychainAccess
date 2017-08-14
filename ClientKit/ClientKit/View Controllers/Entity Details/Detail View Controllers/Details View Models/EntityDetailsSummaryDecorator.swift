//
//  EntityDetailsSummaryDecorator.swift
//  ClientKit
//
//  Created by RUI WANG on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension EntityDetailCollectionViewCell: EntityDetailsSummaryDecoratable {
    
    public func decorate(with entityDetailsSummary: EntityDetailsSummaryDisplayable) {
        sourceLabel.text         = entityDetailsSummary.category
        titleLabel.text          = entityDetailsSummary.title
        subtitleLabel.text       = entityDetailsSummary.subtitle
        descriptionLabel.text    = entityDetailsSummary.description
        isDescriptionPlaceholder = entityDetailsSummary.isPlaceholder
        additionalDetailsButton.setTitle(entityDetailsSummary.additonalButtonTitle, for: .normal)
        
        if let thumbnailInfo = entityDetailsSummary.thumbnail(ofSize: .large) {
            thumbnailView.imageView.contentMode = thumbnailInfo.mode
            thumbnailView.imageView.image = thumbnailInfo.image
        } else {
            thumbnailView.imageView.image = nil
        }
        
        thumbnailView.borderColor = entityDetailsSummary.alertColor
    }
}
