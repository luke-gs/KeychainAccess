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
    
    public var badgeText: String
    public var badgeTextColor: UIColor
    public var badgeFillColor: UIColor
    public var badgeBorderColor: UIColor
    public var usesDarkBackground: Bool
    
    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?,badgeText: String, badgeTextColor: UIColor, badgeFillColor: UIColor, badgeBorderColor: UIColor, usesDarkBackground: Bool) {
        self.badgeText = badgeText
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.usesDarkBackground = usesDarkBackground
        super.init(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
