//
//  BaseFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 18/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit



/// BaseFormItem for a CollectionViewFormCell.
open class BaseFormItem: NSObject, FormItem {

    /// Defines the width of the item to be displayed.
    ///
    /// - intrinsic: Uses item's intrinsic size
    /// - fixed: Uses a fixed points system. E.g. 250 points.
    /// - column: Uses column system. E.g. `column(3)` indicates that the item would
    ///           occupy 1/3 of the full content width. `column(2)` would occupy half of
    ///           the full content width, and `column(1)` indicates full content width.
    /// - dynamic: Use this to provide a custom width based on the info provided. Use this
    ///            if the other styles are ineffective.
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


    /// Defines the height of the item to be displayed.
    ///
    /// - intrinsic: Uses item's intrinsic size
    /// - fixed: Uses a fixed points system. E.g. 250 points.
    /// - dynamic: Use this to provide a custom height based on the info provided. Use this
    ///            if the other styles are ineffective.
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


    // MARK: - Identifiers

    /// For identification purposes, eg. "firstname"
    public var elementIdentifier: String?


    // MARK: - Item properties

    public let cellType: CollectionViewFormCell.Type

    public var reuseIdentifier: String

    public var accessory: ItemAccessorisable?

    public var editActions: [CollectionViewFormEditAction] = []

    /// Text to display below the item.
    public var focusedText: String? {
        didSet {
            if focusedText != oldValue {
                updateFocusedText()
            }
        }
    }

    /// Setting this property causes the item be in focused, which is shown with a red underline. Default to false.
    public var isFocused: Bool = false


    // MARK: - Sizing

    /// Preferred width. Default to `.intrinsic`
    public var width: HorizontalDistribution = .intrinsic

    /// Preferred height. Default to `.intrinsic`
    public var height: VerticalDistribution = .intrinsic


    // MARK: - Styling

    public var contentMode: UIViewContentMode = .center

    public var selectionStyle: CollectionViewFormCell.SelectionStyle = .none

    public var highlightStyle: CollectionViewFormCell.HighlightStyle = .none

    public var separatorStyle: CollectionViewFormCell.SeparatorStyle = .indented


    // MARK: - Colors

    /// Defines the custom separator color. Setting this will take precedent over the theme.
    public var separatorColor: UIColor?

    /// Defines the custom separatorTintColor. Setting this will take precedent over the theme.
    public var separatorTintColor: UIColor?

    /// Defines the custom separator color. Setting this will take precedent over the theme.
    public var focusColor: UIColor?


    // MARK: - Custom Handlers

    /// A custom configuration handler. This is called after the cell has been configured. Use this when
    /// a custom configuration is required.
    public var onConfigured: ((CollectionViewFormCell) -> ())?

    /// A custom theme changed handler. Called after theme has been applied.
    public var onThemeChanged: ((CollectionViewFormCell, Theme) -> ())?

    /// A custom selection handler. Called when the item is selected.
    public var onSelection: ((CollectionViewFormCell) -> ())?


    // MARK: - Initializer

    public init(cellType: CollectionViewFormCell.Type, reuseIdentifier: String) {
        self.cellType = cellType
        self.reuseIdentifier = reuseIdentifier
    }


    // MARK: - Visitor

    public func accept(_ visitor: FormVisitor) {
        visitor.visit(self)
    }


    // MARK: - Collection View Related methods. These methods are called by the form system.

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
            return layout.columnContentWidth(forMinimumItemContentWidth: BaseFormItem.minimumEnforcedContentWidth(for: traitCollection), maximumColumnCount: max, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: UIScreen.main.scale)
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

        // Subclass to apply theme
        apply(theme: theme, toCell: cell)

        // Custom theme configuration if any
        onThemeChanged?(cell, theme)
    }

    // MARK: - Private

    private func reload(_ cell: CollectionViewFormCell) {
        cell.contentMode = contentMode

        // Apply style
        cell.selectionStyle = selectionStyle
        cell.highlightStyle = highlightStyle
        cell.separatorStyle = separatorStyle

        // Apply custom actions
        cell.accessoryView = accessory?.view()
        cell.editActions = editActions

        // Apply focused text
        cell.setRequiresValidation(focusedText?.isEmpty == false || isFocused, validationText: focusedText, animated: false)

        // Subclass cell configuration
        configure(cell)

        // Custom configuration if any
        onConfigured?(cell)
    }


    /// Minimum item width.
    ///
    /// - Parameter traitCollection: Trait collection
    /// - Returns: The width
    private final class func minimumEnforcedContentWidth(for traitCollection: UITraitCollection) -> CGFloat {
        let extraLargeText: Bool
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        return extraLargeText ? 250.0 : 140.0
    }


    // MARK: - Requires Subclass Implementation


    /// Subclass to override.
    ///
    /// - Parameter cell: The cell with the defined cell type
    open func configure(_ cell: CollectionViewFormCell) {
        MPLRequiresConcreteImplementation()
    }


    /// Subclass to override.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view
    ///   - layout: The form layout
    ///   - sectionEdgeInsets: The edge insets
    ///   - traitCollection: The trait collection
    /// - Returns: The intrinsic width of the item
    open func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        MPLRequiresConcreteImplementation()
    }


    /// Subclass to override.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view
    ///   - layout: THe form layout
    ///   - contentWidth: The content width
    ///   - traitCollection: The trait collection
    /// - Returns: The intrinsic height of the item
    open func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        MPLRequiresConcreteImplementation()
    }


    /// Override to apply theme to the cell
    ///
    /// - Parameters:
    ///   - theme: Current theme
    ///   - cell: Current cell
    open func apply(theme: Theme, toCell cell: CollectionViewFormCell) { }


    // MARK: - View updating

    /// The active cell if it is currently displayed on the screen.
    public internal(set) weak var cell: CollectionViewFormCell?

    /// The active collectionView
    public internal(set) weak var collectionView: UICollectionView?

    /// Updates and animates focused text live
    private func updateFocusedText() {
        if let cell = cell {
            cell.setRequiresValidation(focusedText?.isEmpty == false || isFocused, validationText: focusedText, animated: true)
        } else {
            collectionView?.performBatchUpdates({
                collectionView?.collectionViewLayout.invalidateLayout()
            })
        }
    }

    /// Reloads item. This causes the cell to be configured again.
    public func reloadItem() {
        if let cell = cell {
            reload(cell)
        }
    }

}

// MARK: - Chaning Methods

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
    public func contentMode(_ contentMode: UIViewContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }

    @discardableResult
    public func selectionStyle(_ selectionStyle: CollectionViewFormCell.SelectionStyle) -> Self {
        self.selectionStyle = selectionStyle
        return self
    }

    @discardableResult
    public func highlightStyle(_ highlightStyle: CollectionViewFormCell.HighlightStyle) -> Self {
        self.highlightStyle = highlightStyle
        return self
    }

    @discardableResult
    public func separatorStyle(_ separatorStyle: CollectionViewFormCell.SeparatorStyle) -> Self {
        self.separatorStyle = separatorStyle
        return self
    }

    @discardableResult
    public func separatorColor(_ separatorColor: UIColor?) -> Self {
        self.separatorColor = separatorColor
        return self
    }

    @discardableResult
    public func separatorTintColor(_ separatorTintColor: UIColor?) -> Self {
        self.separatorTintColor = separatorTintColor
        return self
    }

    @discardableResult
    public func focusColor(_ focusColor: UIColor?) -> Self {
        self.focusColor = focusColor
        return self
    }

    @discardableResult
    public func accessory(_ accessory: ItemAccessorisable?) -> Self {
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
