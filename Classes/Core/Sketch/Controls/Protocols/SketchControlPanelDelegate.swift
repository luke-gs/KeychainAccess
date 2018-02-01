//
//  SketchControlPanelDelegate.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol SketchControlPanelDelegate: class {

    /// Called when the panel selects a color. Used to handle changes that the delegate
    /// may or may not be interested in
    ///
    /// - Parameters:
    ///   - panel: The panel that did select
    ///   - color: The color that was selected
    func controlPanel(_ panel: SketchControlPanel, didSelectColor color: UIColor)


    /// Called when the control panel changes the mode of drawing
    /// Delegate can then perform any changes that are wanted as a result
    ///
    /// - Parameters:
    ///   - panel: The control panel in question
    ///   - mode: The new drawing mode that was selected from the panel
    func controlPanel(_ panel: SketchControlPanel, didChangeDrawMode mode: SketchMode)

    /// Called when the panels width selection view is touched
    /// The delegate can then handle presenting a view controller
    /// or a form that can handle the selection
    /// - Parameter panel: The panel that triggered the selection
    func controlPanelDidSelectWidth(_ panel: SketchControlPanel)
}
