//
//  CoreGraphics+Convenience.swift
//  MPOLKit
//
//  Created by Rod Brown on 1/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import CoreGraphics

extension CGSize {
    
    public static var max: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    public var isEmpty: Bool {
        return width <=~ 0.0 || height <=~ 0.0
    }
    
}


extension CGRect {
    
    public func insetBy(_ edgeInsets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, edgeInsets)
    }
    
    func rtlFlipped(forWidth width: CGFloat) -> CGRect {
        var rect = self
        rect.origin.x = width - maxX
        return rect
    }
    
}
