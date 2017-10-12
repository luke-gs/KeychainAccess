//
//  BaseSupplementaryFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 20/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


open class BaseSupplementaryFormItem: FormItem {

    /// MARK: - Identifiers

    public var elementIdentifier: String?


    /// MARK: - Item properties

    public let viewType: UICollectionReusableView.Type

    public let kind: String

    public var reuseIdentifier: String


    /// MARK: - Custom Handlers

    public var onConfigured: ((UICollectionReusableView) -> ())?

    public var onThemeChanged: ((UICollectionReusableView, Theme) -> ())?


    /// MARK: - Initiailizer

    public init(viewType: UICollectionReusableView.Type, kind: String, reuseIdentifier: String) {
        self.viewType = viewType
        self.kind = kind
        self.reuseIdentifier = reuseIdentifier
    }

    open func accept(_ visitor: FormVisitor) {
        visitor.visit(self)
    }

    /// MARK: - Collection view related methods. These are called by the form system.

    func view(in collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
        configure(view)
        onConfigured?(view)
        return view
    }

    func decorate(_ view: UICollectionReusableView, withTheme theme: Theme) {
        apply(theme: theme, toView: view)
        onThemeChanged?(view, theme)
    }

    /// MARK: - Requires Subclass Implementation


    /// Subclass to override.
    ///
    /// - Parameter view: The view with the defined type.
    open func configure(_ view: UICollectionReusableView) {
        MPLRequiresConcreteImplementation()
    }


    /// Subclass to override.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - layout: The form layout.
    ///   - traitCollection: The trait collection.
    /// - Returns: The instrinsic height of the item.
    open func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        MPLRequiresConcreteImplementation()
    }


    /// Overide to apply theme to the view
    ///
    /// - Parameters:
    ///   - theme: Current theme
    ///   - view: Current view
    open func apply(theme: Theme, toView view: UICollectionReusableView) { }

}


/// MARK: - Chaining methods

extension BaseSupplementaryFormItem {

    @discardableResult
    public func elementIdentifier(_ elementIdentifier: String?) -> Self {
        self.elementIdentifier = elementIdentifier
        return self
    }

    @discardableResult
    public func reuseIdentifier(_ reuseIdentifier: String) -> Self {
        self.reuseIdentifier = reuseIdentifier
        return self
    }

    @discardableResult
    public func onConfigured(_ configure: ((UICollectionReusableView) -> ())?) -> Self {
        self.onConfigured = configure
        return self
    }

    @discardableResult
    public func onThemeChanged(_ onThemeChanged: ((UICollectionReusableView, Theme) -> ())?) -> Self {
        self.onThemeChanged = onThemeChanged
        return self
    }

}
