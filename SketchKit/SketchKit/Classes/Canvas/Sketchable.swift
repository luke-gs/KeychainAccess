//
//  Sketchable.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol Sketchable {
    var currentTool: TouchTool { get }

    /// Sketch mode of the canvas -> The options currently are
    /// Draw and Erase
    var sketchMode: SketchMode { get set }

    /// Can be used to find out if the sketchable object is empty
    var isEmpty: Bool { get }

    /// The image that has been captured on the device
    /// after the user finishes sketching
    func renderedImage() -> UIImage?

    func setToolColor(_ color: UIColor)
    func setToolWidth(_ width: CGFloat)
}
