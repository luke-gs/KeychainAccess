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
    
    
    /// Dequeues a cell with the reuse identifier for the class.
    ///
    /// - Important: The cell class must have been registered with the table view prior to using this method.
    /// - Parameters:
    ///   - cellClass: The cell class to dequeue.
    ///   - indexPath: The index path to dequeue a cell for.
    /// - Returns: A correctly typed cell dequeued for use in the table view.
    public func dequeueReusableCell<T: UITableViewCell>(of cellClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.defaultReuseIdentifier, for: indexPath) as! T
    }
    
}
