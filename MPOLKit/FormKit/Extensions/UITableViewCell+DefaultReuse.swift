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

    
    /// Applies layout margins to the cell.
    ///
    /// - Parameter layoutMargins: The margins to apply.
    public func apply(_ layoutMargins: UIEdgeInsets) {
        // Left and right margins should be applied to the cell itself. This ensures the separators and accessories are adjusted correctly.
        var cellLayoutMargins   = self.layoutMargins
        cellLayoutMargins.left  = layoutMargins.left
        cellLayoutMargins.right = layoutMargins.right
        self.layoutMargins      = cellLayoutMargins
        
        // Top and bottom margins should be applied to the content view. They don't translate from the cell to the content view.
        let contentView = self.contentView
        var contentLayoutMargins    = contentView.layoutMargins
        contentLayoutMargins.top    = layoutMargins.top
        contentLayoutMargins.bottom = layoutMargins.bottom
        contentView.layoutMargins   = contentLayoutMargins
    }
    
}
