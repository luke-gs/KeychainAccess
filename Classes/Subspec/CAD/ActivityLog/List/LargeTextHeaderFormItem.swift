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
    public var layoutMargins: UIEdgeInsets? = UIEdgeInsets(top: 16, left: 24, bottom: 24, right: 24)
    public var separatorColor: UIColor?

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
                .sizing(defaultNumberOfLines: 1, defaultFont: CollectionViewFormLargeTextLabelCell.defaultFont)
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
                cell.titleLabel.apply(sizable: attributedText, defaultFont: cell.titleLabel.font)
                cell.titleLabel.attributedText = attributedText
            } else {
                cell.titleLabel.apply(sizable: text, defaultFont: cell.titleLabel.font)
            }
            
            cell.separatorView.backgroundColor = separatorColor ?? iOSStandardSeparatorColor
        }
    }

    open override func apply(theme: Theme, toView view: UICollectionReusableView) {
        super.apply(theme: theme, toView: view)

        if let cell = view as? CollectionViewFormLargeTextLabelCell {
            if text?.sizing().attributedString == nil {
                cell.titleLabel.textColor = theme.color(forKey: .primaryText)
            }
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
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }
    
    @discardableResult
    public func separatorColor(_ separatorColor: UIColor?) -> Self {
        self.separatorColor = separatorColor
        return self
    }
}
