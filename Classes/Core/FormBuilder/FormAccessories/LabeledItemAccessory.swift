//
//  LabeledItemAccessory.swift
//  MPOLKit
//
//  Created by KGWH78 on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class LabeledItemAccessory: ItemAccessorisable {

    public var accessory: ItemAccessorisable?

    public let title: String?

    public let subtitle: String?

    public var titleColor: UIColor?

    public var subtitleColor: UIColor?

    public var size: CGSize {
        return view().sizeThatFits(UILayoutFittingCompressedSize)
    }

    public var onThemeChanged: ((Theme, LabeledAccessoryView) -> ())?

    public init(title: String?, subtitle: String?, accessory: ItemAccessorisable? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory
    }

    public func view() -> UIView {
        let view = LabeledAccessoryView()
        view.titleLabel.text = title
        view.subtitleLabel.text = subtitle
        view.accessoryView = accessory?.view()
        return view
    }

    public func apply(theme: Theme, toView view: UIView) {
        guard let view = (view as? LabeledAccessoryView) else { return }
        view.titleLabel.textColor = titleColor ?? theme.color(forKey: .primaryText)
        view.subtitleLabel.textColor = subtitleColor ?? theme.color(forKey: .secondaryText)

        if let accesoryView = view.accessoryView {
            accessory?.apply(theme: theme, toView: accesoryView)
        }

        onThemeChanged?(theme, view)
    }

    /// MARK: - Chaining methods

    public func accessory(_ accessory: ItemAccessorisable?) -> Self {
        self.accessory = accessory
        return self
    }

    public func titleColor(_ titleColor: UIColor?) -> Self {
        self.titleColor = titleColor
        return self
    }

    public func subtitleColor(_ subtitleColor: UIColor?) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }

    public func onThemeChanged(_ onThemeChanged: ((Theme, LabeledAccessoryView) -> ())?) -> Self {
        self.onThemeChanged = onThemeChanged
        return self
    }
}
