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
    
    var wantsTransparentBackground: Bool { get set }
    
}

