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
    
//    var color: UIColor {
//        switch self {
//        case .unassigned:
//            return UIColor(red: 76.0 / 255.0, green: 175.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
//        case .assigned, .tasked:
//            return #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
//        case .duress:
//            return UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
//        }
//    }
}
