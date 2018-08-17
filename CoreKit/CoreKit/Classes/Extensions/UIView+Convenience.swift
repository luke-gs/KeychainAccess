//
//  UIView+Convenience.swift
//  MPOLKit
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
    public func superview<T>(of type: T.Type) -> T? where T: UIView {
        var superview = self.superview
        
        while let superView = superview {
            if let superView = superView as? T {
                return superView
            }
            superview = superView.superview
        }
        
        return nil
    }
    
    
    /// Searches for all subviews of the specified type throughout the
    /// view hierarchy.
    ///
    /// - Important: This search is relatively expensive, and checks all
    ///   nodes in the view heirarchy. You should avoid using this method
    ///   except where necessary.
    ///
    /// - Parameter type: The type searched for.
    /// - Returns: An array of subviews found in the view heirarchy.
    public func allSubviews<T: UIView>(of type: T.Type) -> [T] {
        var foundSubviews: [T] = []
        
        for subview in subviews {
            if let foundSubview = subview as? T {
                foundSubviews.append(foundSubview)
            }
            
            foundSubviews += subview.allSubviews(of: type)
        }
        
        return foundSubviews
    }
    
    
    /// Finds the subview which is currently the first responder, if any.
    ///
    /// - Important: This search is relatively expensive, and checks all
    ///   nodes in the view heirarchy. You should avoid using this method
    ///   except where necessary.
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
