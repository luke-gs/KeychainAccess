//
//  ResourceAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

public class ResourceAnnotation: TaskAnnotation {
    
    public var icon: UIImage?
    public var iconBackgroundColor: UIColor
    public var blinking: Bool
    
    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, iconBackgroundColor: UIColor, blinking: Bool) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.blinking = blinking
        super.init(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
