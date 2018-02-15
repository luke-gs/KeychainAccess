//
//  PatrolAnnotation.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

open class PatrolAnnotation: TaskAnnotation {
    public var usesDarkBackground: Bool

    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, usesDarkBackground: Bool) {
        self.usesDarkBackground = usesDarkBackground
        super.init(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
