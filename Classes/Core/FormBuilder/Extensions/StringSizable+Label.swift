//
//  StringSizable+Label.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

internal let requiredString = "*"
internal let requiredColor = UIColor(red: 1.0, green: 59.0 / 255.0, blue: 48.0 / 255, alpha: 1.0)

extension StringSizing {

    internal mutating func makeRequired() {
        self.string.append(requiredString)
    }

}

extension UILabel {

    public func apply(sizable: StringSizable?, defaultFont: UIFont, defaultNumberOfLines: Int = 1) {
        var text: String?
        var numberOfLines: Int?
        var font: UIFont?

        if let title = sizable as? String {
            text = title
        } else if let sizable = sizable?.sizing() {
            text = sizable.string
            font = sizable.font
            numberOfLines = sizable.numberOfLines
        }

        self.text = text
        self.font = font ?? defaultFont
        self.numberOfLines = numberOfLines ?? defaultNumberOfLines
    }

    internal func makeRequired(with sizable: StringSizable?) {
        let text = sizable?.sizing().string ?? ""
        let title = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: textColor])
        title.append(NSAttributedString(string: requiredString, attributes: [NSForegroundColorAttributeName: requiredColor]))
        self.attributedText = title
    }

}

extension FormTextField {

    public func applyText(sizable: StringSizable?, defaultFont: UIFont) {
        var text: String?
        var font: UIFont?

        if let title = sizable as? String {
            text = title
        } else if let sizable = sizable?.sizing() {
            text = sizable.string
            font = sizable.font
        }

        self.text = text
        self.font = font ?? defaultFont
    }

    public func applyPlaceholder(sizable: StringSizable?, defaultFont: UIFont) {
        var text: String?
        var font: UIFont?

        if let title = sizable as? String {
            text = title
        } else if let sizable = sizable?.sizing() {
            text = sizable.string
            font = sizable.font
        }

        self.placeholder = text
        self.placeholderFont = font ?? defaultFont
    }

}

extension FormTextView {

    public func apply(sizable: StringSizable?, defaultFont: UIFont) {
        var text: String?
        var font: UIFont?

        if let title = sizable as? String {
            text = title
        } else if let sizable = sizable?.sizing() {
            text = sizable.string
            font = sizable.font
        }

        self.text = text
        self.font = font ?? defaultFont
    }

}
