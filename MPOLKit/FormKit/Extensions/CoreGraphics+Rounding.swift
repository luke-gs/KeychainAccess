//
//  CoreGraphics+Rounding.swift
//  VCom
//
//  Created by Rod Brown on 12/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    
    /// Returns the value floored to the appropriate scale factor
    public func floored(toScale scale: CGFloat) -> CGFloat {
        return floor(self * scale) / scale
    }
    
    /// Returns the value ceiled to the appropriate scale factor
    public func ceiled(toScale scale: CGFloat) -> CGFloat {
        return ceil(self * scale) / scale
    }
    
    /// Returns the value rounded to the appropriate scale factor
    public func rounded(toScale scale: CGFloat) -> CGFloat {
        return (self * scale).rounded() / scale
    }
    
}

extension CGSize {
    
    public var isEmpty: Bool {
        return width.isZero || height.isZero
    }
    
}
