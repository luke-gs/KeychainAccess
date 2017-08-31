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
        // TODO: Swift 4 refactor with Switch using open ranges.
        if numberOfLines <= 0 { return .greatestFiniteMagnitude }
        
        if numberOfLines == 1 {
            return lineHeight
        }

        return (lineHeight + leading) * CGFloat(numberOfLines) - leading
    }
    
}
