//
//  IncidentAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

public class IncidentAnnotation: TaskAnnotation {
    
    public var iconText: String
    public var iconColor: UIColor
    public var iconFilled: Bool
    public var usesDarkBackground: Bool
    
    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, iconText: String, iconColor: UIColor, iconFilled: Bool, usesDarkBackground: Bool) {
        self.iconText = iconText
        self.iconColor = iconColor
        self.iconFilled = iconFilled
        self.usesDarkBackground = usesDarkBackground
        super.init(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
