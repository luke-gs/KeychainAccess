//
//  IncidentPersonViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentPersonViewModel: EntitySummaryDisplayable {
    
    public required init(_ entity: MPOLKitEntity) {
        MPLUnimplemented()
    }
    
    public init(category: String?, initials: String, title: String?, detail1: String?, detail2: String?, borderColor: UIColor?, badge: UInt) {
        self.category = category
        self.initials = initials
        self.title = title
        self.detail1 = detail1
        self.detail2 = detail2
        self.borderColor = borderColor
        self.badge = badge
    }
    
    public var initials: String?

    public var category: String?
    
    public var title: String?
    
    public var detail1: String?
    
    public var detail2: String?
    
    public var borderColor: UIColor?
    
    public var iconColor: UIColor?

    public var badge: UInt
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        // TODO: Work out how this works
        return nil
    }

}
