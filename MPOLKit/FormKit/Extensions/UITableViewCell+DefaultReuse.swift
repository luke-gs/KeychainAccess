//
//  UITableViewCell+DefaultReuse.swift
//  VCom
//
//  Created by Val on 4/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    
    /// The default reuse identifier for the cell within a table view.
    /// 
    /// - Important: This reuse identifier is based on the cell's class name, and thus
    ///              you should be careful to avoid registering or using reuse IDs that
    ///              are similar to the class name with table views where you are also
    ///              using this method.
    public dynamic class var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }

}
