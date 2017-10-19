//
//  CallsignListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListItemViewModel {
    
    open var title: String
    open var subtitle: String
    open var image: UIImage?
    open var imageColor: UIColor?
    open var badgeText: String?
    open var badgeTextColor: UIColor?
    open var badgeFillColor: UIColor?
    open var badgeBorderColor: UIColor?
    
    public init(title: String, subtitle: String, image: UIImage?, imageColor: UIColor?, badgeText: String? = nil, badgeTextColor: UIColor? = .clear, badgeFillColor: UIColor? = .clear, badgeBorderColor: UIColor? = .clear) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageColor = imageColor
        self.badgeText = badgeText
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
    }
}
