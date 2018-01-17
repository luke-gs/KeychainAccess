//
//  TouchTool.swift
//  Sketchy
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import UIKit

/// This protocol defines the functionality required for a basic tool
/// that is used to draw onto a canvas
/// It essentially responds to touches from a view that are passed
/// down and determines how to draw between the points
public protocol TouchTool {
    func touch(_ touch: UITouch, beganIn canvas: UIImageView)
    func moved(touch: UITouch)
    func ended(touch: UITouch)

    var toolWidth: CGFloat { get set }
    var toolColor: UIColor { get set }

    func endDrawing()
}
