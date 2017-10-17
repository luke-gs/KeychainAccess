//
//  NotBookedOnItem.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class NotBookedOnItem {
    var title: String
    var subtitle: String
    var image: UIImage?
    var imageColor: UIColor?
    
    init(title: String, subtitle: String, image: UIImage?, imageColor: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageColor = imageColor
    }
}
