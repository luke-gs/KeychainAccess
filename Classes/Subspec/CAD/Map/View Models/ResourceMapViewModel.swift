//
//  ResourceMapViewModel.swift
//  ClientKit
//
//  Created by Kyle May on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

public struct ResourceMapViewModel {
    public var identifier: String
    public var title: String
    public var subtitle: String
    public var coordinate: CLLocationCoordinate2D
    public var iconImage: UIImage?
    public var iconColor: UIColor
    public var pulsing: Bool
}

