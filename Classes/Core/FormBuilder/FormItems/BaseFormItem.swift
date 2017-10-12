//
//  BaseFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit



open class BaseFormItem: NSObject, FormItem {

    public enum HorizontalDistribution {
        case intrinsic
        case fixed(CGFloat)
        case column(Int)
        case dynamic((Info) -> CGFloat)

        public struct Info {
            public let collectionView: UICollectionView
            public let layout: CollectionViewFormLayout
            public let edgeInsets: UIEdgeInsets
            public let traitCollection: UITraitCollection

            public init(collectionView: UICollectionView, layout: CollectionViewFormLayout, edgeInsets: UIEdgeInsets, traitCollection: UITraitCollection) {
                self.collectionView = collectionView
                self.layout = layout
                self.edgeInsets = edgeInsets
                self.traitCollection = traitCollection
            }
        }
    }


    public enum VerticalDistribution {
        case intrinsic
        case fixed(CGFloat)
        case dynamic((Info) -> CGFloat)

        public struct Info {
            public let collectionView: UICollectionView
            public let layout: CollectionViewFormLayout
            public let contentWidth: CGFloat
            public let traitCollection: UITraitCollection

            public init(collectionView: UICollectionView, layout: CollectionViewFormLayout, contentWidth: CGFloat, traitCollection: UITraitCollection) {
                self.collectionView = collectionView
                self.layout = layout
                self.contentWidth = contentWidth
                self.traitCollection = traitCollection
            }
        }
    }


    /// MARK: - Identifiers

    /// For identification purposes, eg. "firstname"
    public var elementIdentifier: String?


    /// MARK: - Item properties

    public let cellType: CollectionViewFormCell.Type

    public var reuseIdentifier: String

    public var accessory: BaseFormItemAccessorisable?

    public var editActions: [CollectionViewFormEditAction] = []

    public var focusedText: String? {
        didSet {
            if focusedText != oldValue {
                updateFocusedText()
            }
        }
    }

    public var isFocused: Bool = false


    /// MARK: - Sizing

    public var width: HorizontalDistribution = .intrinsic

    public var height: VerticalDistribution = .intrinsic


    /// MARK: - Styling

    public var contentMode: UIViewContentMode = .center

    public var selectionStyle: CollectionViewFormCell.SelectionStyle = .none

    public var highlightStyle: CollectionViewFormCell.HighlightStyle = .none

    public var separatorStyle: CollectionViewFormCell.SeparatorStyle = .indented


    /// MARK: - Colors

    public var separatorColor: UIColor?

    public var separatorTintColor: UIColor?

    public var focusColor: UIColor?


    /// MARK: - Custom Handlers

    public var onConfigured: ((CollectionViewFormCell) -> ())?

    public var onThemeChanged: ((CollectionViewFormCell, Theme) -> ())?

    public var onSelection: ((CollectionViewFormCell) -> ())?


    /// MARK: - Initializer

    public init(cellType: CollectionViewFormCell.Type, reuseIdentifier: String) {
        self.cellType = cellType
        self.reuseIdentifier = reuseIdentifier
    }


    /// MARK: - Visitor

    public func accept(_ visitor: FormVisitor) {
        visitor.visit(self)
    }


    /// MARK: - Collection View Related methods

    func cell(forItemAt indexPath: IndexPath, inCollectionView collectionView: UICollectionView) -> CollectionViewFormCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewFormCell
        reload(cell)
        return cell
    }

    func minimumContentHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        switch height {
        case .intrinsic:
            return intrinsicHeight(in: collectionView, layout: layout, givenContentWidth: contentWidth, for: traitCollection)
        case .fixed(let points):
            return points
        case .dynamic(let handler):
            let info = VerticalDistribution.Info(collectionView: collectionView, layout: layout, contentWidth: contentWidth, traitCollection: traitCollection)
            return handler(info)
        }
    }

    func minimumContentWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {

        switch width {
        case .intrinsic:
            return intrinsicWidth(in: collectionView, layout: layout, sectionEdgeInsets: sectionEdgeInsets, for: traitCollection)
        case .column(let max):
            return layout.columnContentWidth(forMinimumItemContentWidth: minimumItemContentWidth(for: traitCollection), maximumColumnCount: max, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: UIScreen.main.scale)
        case .fixed(let points):
            return points
        case .dynamic(let handler):
            let info = HorizontalDistribution.Info(collectionView: collectionView, layout: layout, edgeInsets: sectionEdgeInsets, traitCollection: traitCollection)
            return handler(info)
        }
    }

    func heightForValidationAccessory(givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return cellType.heightForValidationAccessory(withText: focusedText ?? "", contentWidth: contentWidth, compatibleWith: traitCollection)
    }

    func decorate(_ cell: CollectionViewFormCell, withTheme theme: Theme) {
        let separatorColor =  self.separatorColor ?? theme.color(forKey: .separator)
        let focusColor = self.focusColor ?? theme.color(forKey: .validationError)

        cell.separatorColor = separatorColor
        cell.validationColor = focusColor
        cell.separatorTintColor = separatorTintColor

        apply(theme: theme, toCell: cell)
        onThemeChanged?(cell, theme)
    }

    /// MARK: - Private

    private func reload(_ cell: CollectionViewFormCell) {
        cell.contentMode = contentMode

        // Apply style
        cell.selectionStyle = selectionStyle
        cell.highlightStyle = highlightStyle
        cell.separatorStyle = separatorStyle

        // Apply custom actions
        cell.accessoryView = accessory?.view()
        cell.editActions = editActions

        // Apply validations
        cell.setRequiresValidation(focusedText?.isEmpty == false || isFocused, validationText: focusedText, animated: false)

        configure(cell)
        onConfigured?(cell)
    }

    private final func minimumItemContentWidth(for traitCollection: UITraitCollection) -> CGFloat {
        let extraLargeText: Bool
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        return extraLargeText ? 250.0 : 140.0
    }


    /// MARK: - Requires Subclass Implementation

    open func configure(_ cell: CollectionViewFormCell) {
        MPLRequiresConcreteImplementation()
    }

    open func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        MPLRequiresConcreteImplementation()
    }

    open func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        MPLRequiresConcreteImplementation()
    }

    open func apply(theme: Theme, toCell cell: CollectionViewFormCell) { }

    /// MARK: - View updating

    public internal(set) weak var cell: CollectionViewFormCell?

    public func updateFocusedText() {
        cell?.setRequiresValidation(focusedText?.isEmpty == false || isFocused, validationText: focusedText, animated: true)
    }

    public func reloadItem() {
        if let cell = cell {
            reload(cell)
        }
    }

}

/// MARK: - Chaning Methods

extension BaseFormItem {

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
    public func accessory(_ accessory: BaseFormItemAccessorisable?) -> Self {
        self.accessory = accessory
        return self
    }

    @discardableResult
    public func editActions(_ editActions: [CollectionViewFormEditAction]) -> Self {
        self.editActions = editActions
        return self
    }

    @discardableResult
    public func focusedText(_ focusedText: String?) -> Self {
        self.focusedText = focusedText
        return self
    }

    @discardableResult
    public func focused(_ focused: Bool) -> Self {
        self.isFocused = focused
        return self
    }

    @discardableResult
    public func width(_ preferredWidth: HorizontalDistribution) -> Self {
        self.width = preferredWidth
        return self
    }

    @discardableResult
    public func height(_ preferredHeight: VerticalDistribution) -> Self {
        self.height = preferredHeight
        return self
    }

    @discardableResult
    public func onConfigured(_ configure: ((CollectionViewFormCell) -> ())?) -> Self {
        self.onConfigured = configure
        return self
    }

    @discardableResult
    public func onThemeChanged(_ onThemeChanged: ((CollectionViewFormCell, Theme) -> ())?) -> Self {
        self.onThemeChanged = onThemeChanged
        return self
    }

    @discardableResult
    public func onSelection(_ onSelection: ((CollectionViewFormCell) -> ())?) -> Self {
        self.onSelection = onSelection
        return self
    }

}
