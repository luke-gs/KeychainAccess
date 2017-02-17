//
//  UITableView+DefaultReuse.swift
//  VCom
//
//  Created by Rod Brown on 5/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Registers a cell with the default reuse identifier for the class.
    ///
    /// - Important: This method uses the cell's default reuse identifier. Please see
    ///              the limitations with that API to ensure you avoid creating ID conflicts.
    /// - Parameter cellClass: The cell class to register.
    public func register(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.defaultReuseIdentifier)
    }
    
    
    /// Dequeues a cell registered with the default reuse identifier for the class.
    ///
    /// - Parameters:
    ///   - cellClass: The cell class to dequeue.
    ///   - indexPath: The index path to dequeue a cell for.
    ///   - layoutMargins: Layout margins to apply to the cell, if any.
    ///   - preservesTableLayoutMargins: A boolean value indicating if the cell should preserve the table view's layout margins.
    /// - Returns: A correctly typed cell dequeued for use in the table view, with any layout adjustments completed.
    public func dequeueReusableCell<T: UITableViewCell>(of cellClass: T.Type, for indexPath: IndexPath, layoutMargins: UIEdgeInsets? = nil, preservesTableLayoutMargins: Bool = true) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.defaultReuseIdentifier, for: indexPath, layoutMargins: layoutMargins, preservesTableLayoutMargins: preservesTableLayoutMargins) as! T
    }
    
    
    /// Dequeues a cell registered with the specified ID.
    ///
    /// - Parameters:
    ///   - identifier: The identifier to dequeue the cell for.
    ///   - indexPath:  The index path to dequeue the cell for.
    ///   - layoutMargins: Layout margins to apply to the cell, if any.
    ///   - preservesTableLayoutMargins: A boolean value indicating if the cell should preserve the table view's layout margins.
    /// - Returns: A cell dequeued for use in the table view, with any layout adjustments completed.
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath, layoutMargins: UIEdgeInsets?, preservesTableLayoutMargins: Bool = true) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.applyLayoutMargins(layoutMargins, preservingTableViewInsets: preservesTableLayoutMargins)
        return cell
    }
    
    
    public func dequeueReusableCell(withIdenfitier identifier: String, layoutMargins: UIEdgeInsets?, preservesTableLayoutMargins: Bool = true) -> UITableViewCell? {
        let cell = dequeueReusableCell(withIdentifier: identifier)
        cell?.applyLayoutMargins(layoutMargins, preservingTableViewInsets: preservesTableLayoutMargins)
        return cell
    }
}
