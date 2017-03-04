//
//  UIView+Convenience.swift
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
    public func superview<T>(of type: T.Type) -> T? {
        var superview = self.superview
        
        while let superView = superview {
            if let superView = superView as? T {
                return superView
            }
            superview = superView.superview
        }
        
        return nil
    }
    
    /// Finds the subview which is currently the first responder, if any.
    ///
    /// - Important: This method becomes exponentially more complex the deeper
    ///              the view heirarchy is. You should avoid using this method
    ///              on views such as the application's window, where the view
    ///              heirarchy will be at its most complex.
    public func firstResponderSubview() -> UIView? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let firstResponderSubview = subview.firstResponderSubview() {
                return firstResponderSubview
            }
        }
        return nil
    }
    
}
