//
//  EntityDetailSummaryDecorator.swift
//  ClientKit
//
//  Created by RUI WANG on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension EntityDetailCollectionViewCell: EntityDetailSummaryDecoratable {

    public func decorate(with EntityDetailSummary: EntityDetailSummaryDisplayable) {
        sourceLabel.text         = EntityDetailSummary.category
        titleLabel.text          = EntityDetailSummary.title
        subtitleLabel.text       = EntityDetailSummary.subtitle
        descriptionLabel.text    = EntityDetailSummary.description
        isDescriptionPlaceholder = EntityDetailSummary.isPlaceholder
        additionalDetailsButton.setTitle(EntityDetailSummary.additonalButtonTitle, for: .normal)
        
        if let thumbnailInfo = EntityDetailSummary.thumbnail(ofSize: .large) {
            thumbnailView.imageView.contentMode = thumbnailInfo.mode
            thumbnailView.imageView.image = thumbnailInfo.image
        } else {
            thumbnailView.imageView.image = nil
        }

        thumbnailView.borderColor = EntityDetailSummary.alertColor
    }
}
