//
//  EntityMapSummaryDecorator.swift
//  Pods
//
//  Created by RUI WANG on 17/9/17.
//
//

import Foundation

extension LocationMapDirectionCollectionViewCell: EntityMapSummaryDecoratable {
    public func decorate(with locationSummary: EntityMapSummaryDisplayable) {
        descriptionLabel.text = locationSummary.detail2
        selectionStyle = .none
        highlightStyle = .none

        streetViewButton.bottomLabel.text = locationSummary.streetViewButtonTitle

        // Placeholders as the estimated time will be loaded async 
        walkingEstButton.bottomLabel.text = locationSummary.walkingLabelPlaceholder
        automobileEstButton.bottomLabel.text = locationSummary.automobileLabelPlaceholder

        let secondaryTextColor = ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        descriptionLabel.textColor = secondaryTextColor
        distanceLabel.textColor = secondaryTextColor
    }
}
