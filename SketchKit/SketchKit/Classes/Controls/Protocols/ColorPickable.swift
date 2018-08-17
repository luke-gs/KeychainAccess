//
//  ColorPickable.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol ColorPickable {
    static var circleDiameter: CGFloat { get }
    var colorSelectionHandler: ((UIColor) -> ())? { get set }
    var colors: [UIColor] { get }
    func set(_ color: UIColor)
}
