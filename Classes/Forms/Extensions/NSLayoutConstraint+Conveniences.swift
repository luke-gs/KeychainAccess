//
//  NSLayoutConstraint+Conveniences.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/12/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        if priority.rawValue < UILayoutPriority.required.rawValue {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any, attribute attr2: NSLayoutAttribute, multiplier: CGFloat = 1.0, priority: UILayoutPriority = UILayoutPriority.required) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: 0.0)
        if priority.rawValue < UILayoutPriority.required.rawValue {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any, attribute attr2: NSLayoutAttribute, constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: 1.0, constant: constant)
        if priority.rawValue < UILayoutPriority.required.rawValue {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toConstant constant: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: constant)
        if priority.rawValue < UILayoutPriority.required.rawValue {
            self.priority = priority
        }
    }
    
    
    /// Adjusts the priority of the constraint, and returns the constraint.
    ///
    /// - Important: The same caveats for adjusting the priority of live constraints
    ///              apply to this method. That is, adjusting live constraints throws
    ///              an exception within UIKit.
    ///
    /// - Parameter priority: The new priority for the constraint.
    /// - Returns: The layout constraint.
    public func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}
