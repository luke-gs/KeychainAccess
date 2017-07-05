//
//  UIViewController+ParentSearching.swift
//  MPOLKit
//
//  Created by Rod Brown on 5/7/17.
//

import UIKit

extension UIViewController {
    
    /// Returns the nearest parent view controller matching the type specified, or `nil`.
    ///
    /// - Parameter of: The type to search for.
    /// - Returns: The found view controller of the specified type, or nil.
    public func parent<T>(of: T.Type) -> T? where T: UIViewController {
        var parent = self.parent
        
        while let parentViewController = parent {
            if let pushableSplit = parentViewController as? T {
                return pushableSplit
            }
            parent = parentViewController.parent
        }
        
        return nil
    }
    
    
    /// Performs the block for all child view controllers in the view heirarchy, recursively.
    ///
    /// - Parameter block: The block to perform.
    public func forAllChildViewControllers(_ block: (UIViewController) -> Void) {
        childViewControllers.forEach {
            block($0)
            $0.forAllChildViewControllers(block)
        }
    }
    
}
