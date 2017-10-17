//
//  CustomItemAccessory.swift
//  MPOLKit
//
//  Created by KGWH78 on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Custom form item accessory. Use this class to provide a single used accessory.
public class CustomItemAccessory: ItemAccessorisable {

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

    // MARK: - Chaining methods

    public func onThemeChanged(_ onThemeChanged: ((Theme, UIView) -> ())?) -> Self {
        self.onThemeChanged = onThemeChanged
        return self
    }

}
