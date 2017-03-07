//
//  UITableViewCell+LayoutMargins.swift
//  MPOLKit/FormKit
//
//  Created by Rod on 20/02/2017.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    
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
