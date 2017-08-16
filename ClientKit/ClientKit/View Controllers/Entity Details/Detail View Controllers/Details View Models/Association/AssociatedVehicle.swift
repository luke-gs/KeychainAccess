//
//  AssociatedVehicle.swift
//  ClientKit
//
//  Created by RUI WANG on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class AssociatedVehicle: EntitySummaryDisplayable {
    let associate: Vehicle
    
    public required init (associate: Vehicle) {
        self.associate = associate
    }
    
    public var category: String? { return associate.category }
    
    public var title: String? { return associate.title }
    
    public var detail1: String? { return associate.detail1 }
    
    public var detail2: String? { return "Relationship"}
    
    public var alertColor: UIColor? { return associate.alertColor }
    
    public var badge: UInt { return associate.badge }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        return associate.thumbnail(ofSize: size)
    }
}
