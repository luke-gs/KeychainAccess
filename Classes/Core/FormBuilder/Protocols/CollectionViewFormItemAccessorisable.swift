//
//  CollectionViewFormItemAccessorisable.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol CollectionViewFormItemAccessorisable {

    var size: CGSize { get }

    func view() -> UIView

    func apply(theme: Theme, toView view: UIView)

}


public struct FormItemAccessory: CollectionViewFormItemAccessorisable {

    /// MARK: - Static shorthand

    public static let disclosure = FormItemAccessory(style: .disclosure)
    public static let checkmark = FormItemAccessory(style: .checkmark)
    public static let dropDown = FormItemAccessory(style: .dropDown)

    /// MARK: - Properties

    public let style: Style

    public let size: CGSize

    public let tintColor: UIColor?

    public init(style: Style, tintColor: UIColor? = nil) {
        self.style = style
        self.size = FormAccessoryImageView.size(with: style)
        self.tintColor = tintColor
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
    }

}


public class CustomFormItemAccessory: CollectionViewFormItemAccessorisable {

    public let size: CGSize

    public let onCreate: () -> UIView

    public var onThemeChanged: ((Theme, UIView) -> ())?

    public init(onCreate: @escaping () -> UIView, size: CGSize) {
        self.onCreate = onCreate
        self.size = size
    }

    public func view() -> UIView {
        return onCreate()
    }

    public func apply(theme: Theme, toView view: UIView) {
        onThemeChanged?(theme, view)
    }

}
