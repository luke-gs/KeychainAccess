//
//  NSAttributedString+Theme.swift
//  DemoAppKit
//
//  Created by Evan Tsai on 20/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PatternKit
extension NSAttributedString {

    /// Initialise a string with theme's tint
    ///
    /// - Parameter string: The base string
    /// - Returns: The NSAttributedString with theme's tint
    public static func stringWithTint(string: String) -> NSAttributedString {

        var attributes = [NSAttributedStringKey: Any]()

        if let tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint) {
            attributes[.foregroundColor] = tintColor
        }

        return NSAttributedString.init(string: string, attributes: attributes)

    }

}
