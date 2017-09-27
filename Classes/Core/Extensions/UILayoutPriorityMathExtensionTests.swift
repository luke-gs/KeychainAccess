//
//  UILayoutPriority+Math.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UILayoutPriority {


    // MARK: - Static convenience constants

    /// Convenience declaration for UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)
    public static let almostRequired: UILayoutPriority = UILayoutPriority.required - 1

    // MARK: - Operators overloading

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
