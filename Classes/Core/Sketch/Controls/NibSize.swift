//
//  NibSize.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

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

    var image: UIImage? {
        return UIImage.circle(diameter: rawValue, color: .darkGray)
    }

    static var allCases: [NibSize] = [.small, .medium, .large, .giant]
}
