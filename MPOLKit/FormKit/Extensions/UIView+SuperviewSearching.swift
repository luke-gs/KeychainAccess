//
//  UIView+SuperviewSearching.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 25/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Searches for the nearest superview of the specified type.
    ///
    /// - Parameter type: The type searched for.
    /// - Returns: The nearest superview of the specified type, if any.
    func superview<T>(of type: T.Type) -> T? {
        var superview = self.superview
        
        while let superView = superview {
            if let superView = superView as? T {
                return superView
            }
            superview = superView.superview
        }
        
        return nil
    }
    
}
