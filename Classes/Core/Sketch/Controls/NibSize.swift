//
//  NibSize.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// The enum defining the size of the width of the tool
/// Has 4 predefined values, and the ability to initialise
/// with a value that will be converted to the closest value
public enum NibSize: CGFloat {
    case small = 5
    case medium = 25
    case large = 50
    case giant = 100

    init(value: CGFloat) {
        switch value {
        case 5: self = .small
        case 25: self = .medium
        case 50: self = .large
        case 100: self = .giant
        default:

            /// Calculate the closest match the value provided
            /// eg a value of 88 will be set to giant and a value
            /// of 26 would be set to medium.

            let values = NibSize.allCases
            var closestMatch = NibSize.giant
            var closestDelta = CGFloat.infinity
            values.forEach {
                let delta: CGFloat = CGFloat(fabs(Double($0.rawValue - value)))
                if delta < closestDelta {
                    closestMatch = $0
                    closestDelta = CGFloat(delta)
                }
            }
            self = closestMatch
        }
    }

    /// Hardcoded diameters to be displayed in views which the full
    /// diameter would be too large to encase. This is done to
    /// preserve the difference in sizes in smaller views.
    var scaledImage: UIImage? {
        let diameter: CGFloat
        switch self {
        case .small: diameter = 10.0
        case .medium: diameter = 15.0
        case .large: diameter = 20.0
        case .giant: diameter = 25.0
        }

        return UIImage.circle(diameter: diameter, color: .darkGray)
    }

    /// The default image that displays the nibSize in real sizes.
    /// Can be used when selecting a new size, to show the ratio's
    /// between the different options.
    var image: UIImage? {
        return UIImage.circle(diameter: rawValue, color: .darkGray)
    }

    static var allCases: [NibSize] = [.small, .medium, .large, .giant]
}
