//
//  LargeTextHeaderFormItem.swift
//  MPOLKit
//
//  Created by Kyle May on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class LargeTextHeaderFormItem: BaseSupplementaryFormItem {

    public var text: StringSizable?
    public var textAlignment: NSTextAlignment?
    public var layoutMargins: UIEdgeInsets? = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    public var separatorColor: UIColor?
    public var actionButton: UIButton?
    //public var isExpanded: Bool = true
    private var actionButtonHandler: ((UIButton) -> Void)?
    public var sectionIsRequired: Bool = false

    public init() {
        super.init(viewType: CollectionViewFormLargeTextLabelCell.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: CollectionViewFormLargeTextLabelCell.defaultReuseIdentifier)
    }

    public convenience init(text: StringSizable?, separatorColor: UIColor? = nil) {
        self.init()
        self.text = text
        self.separatorColor = separatorColor
    }

    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        var size: CGFloat = 0

        if let text = text {
            size = text
                .sizing(defaultNumberOfLines: 2, defaultFont: CollectionViewFormLargeTextLabelCell.defaultFont)
                .minimumHeight(inWidth: collectionView.bounds.width, compatibleWith: traitCollection)
        }

        if let layoutMargins = layoutMargins {
            size += layoutMargins.top + layoutMargins.bottom
        }

        return size
    }

    open override func configure(_ view: UICollectionReusableView) {
        if let cell = view as? CollectionViewFormLargeTextLabelCell {
            if let layoutMargins = layoutMargins {
                cell.layoutMargins = layoutMargins
            }

            if let sizing = text?.sizing(), let attributedText = sizing.attributedString {
                cell.titleLabel.apply(sizable: attributedText, defaultFont: cell.titleLabel.font, defaultNumberOfLines: 2)
                cell.titleLabel.attributedText = attributedText
            } else {
                cell.titleLabel.apply(sizable: text, defaultFont: cell.titleLabel.font)
            }

            if sectionIsRequired {
                cell.titleLabel.makeRequired(with: text)
            }

            if let textAlignment = textAlignment {
                cell.titleLabel.textAlignment = textAlignment
            }

            cell.separatorView.backgroundColor = separatorColor ?? iOSStandardSeparatorColor

            // Set or remove action button
            cell.actionButton = actionButton
        }
    }

    open override func apply(theme: Theme, toView view: UICollectionReusableView) {
        super.apply(theme: theme, toView: view)

        if let cell = view as? CollectionViewFormLargeTextLabelCell {
            if let text = text {
                if text.sizing().attributedString?
                    .attributeIfExists(.foregroundColor, at: 0, effectiveRange: nil) == nil {
                        cell.titleLabel.textColor = theme.color(forKey: .primaryText)
                }

                if sectionIsRequired {
                    cell.titleLabel.makeRequired(with: text)
                }
            }

            actionButton?.setTitleColor(view.tintColor, for: .normal)
            actionButton?.setTitleColor(view.tintColor.withAlphaComponent(0.5), for: .highlighted)
        }
    }
}

// MARK: - Chaining methods

extension LargeTextHeaderFormItem {

    @discardableResult
    public func text(_ text: StringSizable?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func textAlignment(_ textAlignment: NSTextAlignment?) -> Self {
        self.textAlignment = textAlignment
        return self
    }

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }

    @discardableResult
    public func separatorColor(_ separatorColor: UIColor?) -> Self {
        self.separatorColor = separatorColor
        return self
    }
    
    @discardableResult
    public func actionButton(title: String, handler: @escaping ((UIButton) -> Void)) -> Self {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        button.addTarget(self, action: #selector(actionButtonTapped(button:)), for: .touchUpInside)
        self.actionButton = button
        self.actionButtonHandler = handler
        return self
    }

    @discardableResult
    public func actionButtonHandler(_ handler: @escaping ((UIButton) -> Void)) -> Self {
        self.actionButtonHandler = handler
        return self
    }

    @discardableResult
    public func sectionIsRequired(_ sectionIsRequired: Bool) -> Self {
        self.sectionIsRequired = sectionIsRequired
        return self
    }

    @objc private func actionButtonTapped(button: UIButton) {
        actionButtonHandler?(button)
    }
}
