//
//  UIFont+Convenience.swift
//  MPOLKit
//
//  Created by Rod Brown on 14/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var FontAssociatedTextStyleHandle: UInt8 = 0

extension UIFont {

    public func height(forNumberOfLines numberOfLines: Int) -> CGFloat {

        switch numberOfLines {
        case ..<0:
            return .greatestFiniteMagnitude
        case 1:
            return lineHeight
        default:
            return (lineHeight + leading) * CGFloat(numberOfLines) - leading
        }

    }
    
}
