//
//  SketchColorPickable.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol SketchColorPickable {
    typealias ColorPicker = ColorPickable & UIView

    /// The associated color picker that ensures implementers
    /// have a color picker
    var colorPicker: ColorPicker { get set }


    /// Set the selected color of the color picker
    ///
    /// - Parameter color: The color to set
    func setSelectedColor(_ color: UIColor)
}
