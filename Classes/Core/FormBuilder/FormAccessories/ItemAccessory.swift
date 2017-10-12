//
//  ItemAccessory.swift
//  MPOLKit
//
//  Created by KGWH78 on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public struct ItemAccessory: ItemAccessorisable {

    /// MARK: - Static shorthand

    public static let disclosure = ItemAccessory(style: .disclosure)
    public static let checkmark = ItemAccessory(style: .checkmark)
    public static let dropDown = ItemAccessory(style: .dropDown)


    /// MARK: - Properties

    public let style: Style

    public let size: CGSize

    public var tintColor: UIColor?

    public var onThemeChanged: ((Theme, FormAccessoryImageView) -> ())?

    public init(style: Style) {
        self.style = style
        self.size = FormAccessoryImageView.size(with: style)
    }

    public func view() -> UIView {
        return FormAccessoryImageView(style: style)
    }

    public func apply(theme: Theme, toView view: UIView) {
        guard let view = view as? FormAccessoryImageView else { return }

        if let color = tintColor {
            view.tintColor = color
        } else {
            switch view.style {
            case .checkmark:  view.tintColor = nil
            case .disclosure: view.tintColor = theme.color(forKey: .disclosure)
            case .dropDown:   view.tintColor = theme.color(forKey: .primaryText)
            }
        }

        self.onThemeChanged?(theme, view)
    }

    mutating func tintColor(_ tintColor: UIColor?) -> ItemAccessory {
        self.tintColor = tintColor
        return self
    }

    mutating func onThemeChanged(_ onThemeChanged: ((Theme, FormAccessoryImageView) -> ())?) -> ItemAccessory {
        self.onThemeChanged = onThemeChanged
        return self
    }

}
