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
    
    
    /// Returns a CGSize limited in dimensions to the specified size. The size
    /// returned for width and height will be the min of each of those respective
    /// values from each size.
    ///
    /// - Parameter size: The maximum size for the CGSize
    /// - Returns: The maximum size possible of the receiver, constrained to the
    ///            specified size.
    public func constrained(to size: CGSize) -> CGSize {        
        return CGSize(width:  min(self.width,  size.width),
                      height: min(self.height, size.height))
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
