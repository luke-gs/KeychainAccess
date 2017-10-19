//
//  ItemAccessorisable.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Defines an accessory item that can be used with the form item.
public protocol ItemAccessorisable {

    /// The accessory item size
    var size: CGSize { get }

    /// Generate the view for the accessory item.
    ///
    /// - Returns: The accessory view.
    func view() -> UIView

    /// Allows view to be decorated with the existing theme.
    ///
    /// - Parameters:
    ///   - theme: The current theme.
    ///   - view: The current accessory view.
    func apply(theme: Theme, toView view: UIView)

}
