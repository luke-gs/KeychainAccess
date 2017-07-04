//
//  EntityThumbnailView+Configuration.swift
//  ClientKit
//
//  Created by Rod Brown on 28/6/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import MPOLKit
import UIKit

extension EntityThumbnailView {
    
    // MARK: - Configuration
    
    public func configure(for entity: Entity?, size: ThumbnailSize) {
        if let thumbnail = entity?.thumbnailImage(ofSize: size) {
            imageView.contentMode = thumbnail.mode
            imageView.image = thumbnail.image
        } else {
            imageView.image = nil
        }
        
        borderColor = entity is Person ? entity?.alertLevel?.color : entity?.associatedAlertLevel?.color
    }
    
}
