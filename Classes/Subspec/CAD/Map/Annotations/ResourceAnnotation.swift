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
    public var duress: Bool
    
    public init(identifier: String, source: CADTaskListSourceType, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, iconBackgroundColor: UIColor, iconTintColor: UIColor?, duress: Bool) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconTintColor = iconTintColor
        self.duress = duress
        super.init(identifier: identifier, source: source, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
