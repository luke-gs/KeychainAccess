//
//  StringSizable+Label.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct FormRequired {

    public static let `default` = FormRequired()

    public let symbol = "*"

    public let color = UIColor(red: 1.0, green: 59.0 / 255.0, blue: 48.0 / 255, alpha: 1.0)

    public let message = NSLocalizedString("This is required.", comment: "The default required message.")

    public let requiredPlaceholder = NSLocalizedString("Required", comment: "Form placeholder text - Required")

    public let notRequiredPlaceholder = NSLocalizedString("Optional", comment: "Form placeholder text - Optional")

    public let dropDownAction = NSLocalizedString("Select", comment: "Form placeholder text - Select")

    public func placeholder(withRequired required: Bool) -> String {
        return required ? requiredPlaceholder : notRequiredPlaceholder
    }

}

extension StringSizing {

    /// Appends required string
    public mutating func makeRequired() {
        self.string.append(FormRequired.default.symbol)
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


    /// Make this label become required by assigning it with an attributed text.
    ///
    /// - Parameter sizable: The `StringSizable`
    public func makeRequired(with sizable: StringSizable?) {
        let text = sizable?.sizing().string ?? ""
        let title = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: textColor])
        title.append(NSAttributedString(string: FormRequired.default.symbol, attributes: [NSAttributedStringKey.foregroundColor: FormRequired.default.color]))
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
