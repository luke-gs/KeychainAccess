//
//  SketchEraser.swift
//  Sketchy
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import UIKit

public class SketchyEraser: SketchyPen {

    override init() {
        super.init()
        toolWidth = 50.0
    }

    override var bufferedDrawing: Bool {
        return false
    }

    override func configureContext() {
        super.configureContext()
        UIGraphicsGetCurrentContext()?.setBlendMode(.clear)
    }
}
