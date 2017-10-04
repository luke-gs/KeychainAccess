//
//  IncidentMapViewModel.swift
//  ClientKit
//
//  Created by Kyle May on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

public struct IncidentMapViewModel {
    public var identifier: String
    public var title: String
    public var subtitle: String
    public var coordinate: CLLocationCoordinate2D
    public var iconText: String
    public var iconColor: UIColor
    public var iconFilled: Bool
    public var usesDarkBackground: Bool
}
