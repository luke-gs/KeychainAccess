//
//  PopToRootable.swift
//  MPOLKit
//
//  Created by Kyle May on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A protocol that allows the view controller to pop to the root navigation controller
public protocol PopToRootable: class {
    /// Pops to the root view controller
    func popToRoot(animated: Bool)
}

extension UINavigationController: PopToRootable {
    public func popToRoot(animated: Bool) {
        popToRootViewController(animated: animated)
    }
}
