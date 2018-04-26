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
    public var textColor: UIColor?
    public var layoutMargins: UIEdgeInsets?

    public init() {
        super.init(cellType: CollectionViewFormLabelCell.self, reuseIdentifier: CollectionViewFormLabelCell.defaultReuseIdentifier)
    }

    public convenience init(text: StringSizable?, textColor: UIColor? = nil, separatorColor: UIColor? = nil) {
        self.init()
        self.text = text
        self.textColor = textColor
        self.separatorColor = separatorColor
    }
    
    open override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormLabelCell else { return }
        
        cell.overridesLayoutMargins = layoutMargins == nil
        
        if let layoutMargins = layoutMargins {
            cell.contentView.layoutMargins = layoutMargins
        }
        
        if let sizing = text?.sizing(), let attributedText = sizing.attributedString {
            cell.titleLabel.attributedText = attributedText
            cell.titleLabel.numberOfLines = sizing.numberOfLines ?? 0
        } else {
            cell.titleLabel.apply(sizable: text, defaultFont: CollectionViewFormLabelCell.defaultFont, defaultNumberOfLines: 0)
        }
        
        cell.separatorView.backgroundColor = separatorColor ?? iOSStandardSeparatorColor
    }
    
    open override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormLabelCell else { return }
        
        if text?.sizing(defaultNumberOfLines: 0, defaultFont: CollectionViewFormLabelCell.defaultFont).attributedString == nil {
            cell.titleLabel.textColor = textColor ?? theme.color(forKey: .primaryText)
        }
    }

    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        var size: CGFloat = 0
        
        if let text = text {
            size = text.sizing(defaultNumberOfLines: 0,
                               defaultFont: CollectionViewFormLabelCell.defaultFont)
                .minimumHeight(inWidth: contentWidth, compatibleWith: traitCollection)
        }
        
        if let layoutMargins = layoutMargins {
            size += layoutMargins.top + layoutMargins.bottom
        }
        
        return max(size, CollectionViewFormLabelCell.minimumHeight)
    }
    
    open override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
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
    public func textColor(_ textColor: UIColor?) -> Self {
        self.textColor = textColor
        return self
    }

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets?) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }
}

