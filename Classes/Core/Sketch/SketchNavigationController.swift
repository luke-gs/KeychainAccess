//
//  SketchNavigationController.swift
//  MPOLKit
//
//  Created by QHMW64 on 22/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

// A rotation aware navigation controller
// This is done due to the small devices for iPhones that
// do not have enough screen real-estate to support rotating and
// keeping ratios correct, whilst also being easy to draw on.
//
// Leaves the decision of the orientation and supported orientations
// to the top most view controller in the stack.

final public class SketchNavigationController: UINavigationController {
    override public var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .allButUpsideDown
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
