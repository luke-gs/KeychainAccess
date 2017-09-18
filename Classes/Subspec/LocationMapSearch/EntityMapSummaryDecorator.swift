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
    }
}
