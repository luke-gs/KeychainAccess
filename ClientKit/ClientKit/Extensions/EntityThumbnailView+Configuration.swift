//
//  EntityThumbnailView+Configuration.swift
//  ClientKit
//
//  Created by Rod Brown on 28/6/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import PublicSafetyKit
import UIKit

extension EntityThumbnailView {
    
    // MARK: - Configuration
    
    public func configure(for entity: EntitySummaryDisplayable?, size: ThumbnailSize) {

        if let entity = entity, let thumbnail = entity.thumbnail(ofSize: size) {
            imageView.setImage(with: thumbnail)
        } else {
            imageView.image = nil
        }
        
        borderColor = entity?.borderColor
    }
    
}
