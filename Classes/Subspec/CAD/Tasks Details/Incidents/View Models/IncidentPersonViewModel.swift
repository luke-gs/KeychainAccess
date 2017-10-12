//
//  IncidentPersonViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// TODO: Replace with Person and PersonSummaryDisplayable
public class IncidentPersonViewModel: EntitySummaryDisplayable {
    public required init(_ entity: MPOLKitEntity) {
        MPLUnimplemented()
    }
    
    public init(category: String?, initials: String, title: String?, detail1: String?, detail2: String?, alertColor: UIColor?, badge: UInt) {
        self.category = category
        self.initials = initials
        self.title = title
        self.detail1 = detail1
        self.detail2 = detail2
        self.alertColor = alertColor
        self.badge = badge
    }
    
    public var initials: String?

    public var category: String?
    
    public var title: String?
    
    public var detail1: String?
    
    public var detail2: String?
    
    public var alertColor: UIColor?
    
    public var badge: UInt
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        if let initials = initials?.ifNotEmpty() {
            return (UIImage.thumbnail(withInitials: initials), .scaleAspectFill)
        }
        return nil
    }
    

}
