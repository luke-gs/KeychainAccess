//
//  NotBookedOnItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class NotBookedOnItemViewModel {
    open var title: String
    open var subtitle: String
    open var image: UIImage?
    open var imageColor: UIColor?
    
    public init(title: String, subtitle: String, image: UIImage?, imageColor: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageColor = imageColor
    }
}
