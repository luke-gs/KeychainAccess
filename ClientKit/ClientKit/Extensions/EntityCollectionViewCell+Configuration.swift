//
//  EntityCollectionViewCell+Configuration.swift
//  ClientKit
//
//  Created by Rod Brown on 28/6/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import MPOLKit
import UIKit

extension EntityCollectionViewCell {
    
    open func configure(for entity: Entity?, style: Style) {
        self.style = style
        thumbnailView.configure(for: entity, size: style == .hero ? .large : .medium)
        titleLabel.text    = entity?.summary
        subtitleLabel.text = entity?.summaryDetail1
        detailLabel.text   = entity?.summaryDetail2
        alertColor         = entity?.alertLevel?.color
        badgeCount         = entity?.actionCount ?? 0
        sourceLabel.text   = entity?.source?.localizedBadgeTitle
    }
    
}
