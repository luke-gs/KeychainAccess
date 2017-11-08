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
    public var iconTintColor: UIColor?
    public var pulsing: Bool
    
    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, iconBackgroundColor: UIColor, iconTintColor: UIColor?, pulsing: Bool) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconTintColor = iconTintColor
        self.pulsing = pulsing
        super.init(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
