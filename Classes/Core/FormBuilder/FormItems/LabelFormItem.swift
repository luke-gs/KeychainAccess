//
//  LabelFormItem.swift
//  MPOLKit
//
//  Created by Kyle May on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class LabelFormItem: BaseFormItem {

    public var text: StringSizable?
    public var layoutMargins: UIEdgeInsets?

    public init() {
        super.init(cellType: LargeTextHeaderCollectionViewCell.self, reuseIdentifier: LargeTextHeaderCollectionViewCell.defaultReuseIdentifier)
    }

    public convenience init(text: StringSizable?, separatorColor: UIColor? = nil) {
        self.init()
        self.text = text
        self.separatorColor = separatorColor
    }

    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        var size: CGFloat?
        
        if let text = text, let layoutMargins = layoutMargins {
            size = text.sizing().minimumHeight(inWidth: contentWidth,
                                               compatibleWith: traitCollection)
                + layoutMargins.top + layoutMargins.bottom
        }
        
        if let size = size {
            return size
        }
        
        return LargeTextHeaderCollectionViewCell.minimumHeight
    }
    
    open override func configure(_ view: UICollectionReusableView) {
        if let cell = view as? LargeTextHeaderCollectionViewCell {
            if let layoutMargins = layoutMargins {
                cell.contentView.layoutMargins = layoutMargins
            }

            if let sizing = text?.sizing(), let attributedText = sizing.attributedString {
                cell.titleLabel.attributedText = attributedText
                cell.titleLabel.numberOfLines = sizing.numberOfLines ?? 0
            } else {
                cell.titleLabel.apply(sizable: text, defaultFont: cell.titleLabel.font)
            }

            cell.separatorView.backgroundColor = separatorColor ?? iOSStandardSeparatorColor
        }
    }
}

// MARK: - Chaining methods

extension LabelFormItem {

    @discardableResult
    public func text(_ text: StringSizable?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }
}

