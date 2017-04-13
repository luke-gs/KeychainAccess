//
//  NSLayoutConstraint+Conveniences.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/12/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        if priority < UILayoutPriorityRequired {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any, attribute attr2: NSLayoutAttribute, multiplier: CGFloat = 1.0, priority: UILayoutPriority = UILayoutPriorityRequired) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: 0.0)
        if priority < UILayoutPriorityRequired {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: Any, attribute attr2: NSLayoutAttribute, constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: 1.0, constant: constant)
        if priority < UILayoutPriorityRequired {
            self.priority = priority
        }
    }
    
    public convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toConstant constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: constant)
        if priority < UILayoutPriorityRequired {
            self.priority = priority
        }
    }
    
}
