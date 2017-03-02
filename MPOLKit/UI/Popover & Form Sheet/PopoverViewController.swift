//
//  PopoverViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//


/// A `UIViewController` protocol for classes designed to be compatible with
/// MPOL background translucency, and PopoverNavigationController.
protocol PopoverViewController: class {
    
    /// A boolean value indicating whether the view controller (and its children)
    /// should be translayed with a transparent background.
    var wantsTransparentBackground: Bool { get set }
    
}

