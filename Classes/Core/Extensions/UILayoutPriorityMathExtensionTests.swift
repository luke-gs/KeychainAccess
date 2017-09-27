//
//  UILayoutPriority+Math.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UILayoutPriority {

    public static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        let rawValue = lhs.rawValue + rhs
        return UILayoutPriority(rawValue: rawValue)
    }

    public static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        let rawValue = lhs.rawValue - rhs
        return UILayoutPriority(rawValue: rawValue)
    }

    public static func +=(lhs: inout UILayoutPriority, rhs: Float) {
        lhs = lhs + rhs
    }

    public static func -=(lhs: inout UILayoutPriority, rhs: Float) {
        lhs = lhs - rhs
    }

}
