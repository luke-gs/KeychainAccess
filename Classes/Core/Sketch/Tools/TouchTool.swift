//
//  TouchTool.swift
//  Sketchy
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import UIKit

public protocol TouchTool {
    func touch(_ touch: UITouch, beganIn canvas: UIImageView)
    func moved(touch: UITouch)
    func ended(touch: UITouch)

    var toolWidth: CGFloat { get set }
    var toolColor: UIColor { get set }

    func endDrawing()
}
