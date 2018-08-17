//
//  UIEdgeInsets+InverseAndInset.swift
//  MPOLKit
//
//  Created by Rod Brown on 4/06/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    
    public func inverted() -> UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
    public func horizontallyFlipped() -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: right, bottom: bottom, right: left)
    }
    
}
