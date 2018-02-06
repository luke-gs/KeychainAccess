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
    public var layoutMargins: UIEdgeInsets?

    public init() {
        super.init(viewType: LargeTextHeaderCollectionViewCell.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: LargeTextHeaderCollectionViewCell.defaultReuseIdentifier)
    }
    
    public convenience init(text: StringSizable?) {
        self.init()
        self.text = text
    }
    
    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        if let text = text, let layoutMargins = layoutMargins {
            return text.sizing().minimumHeight(inWidth: collectionView.bounds.width, compatibleWith: traitCollection) + layoutMargins.top + layoutMargins.bottom
        }
        return LargeTextHeaderCollectionViewCell.minimumHeight
    }

    open override func configure(_ view: UICollectionReusableView) {
        if let cell = view as? LargeTextHeaderCollectionViewCell {
            if let layoutMargins = layoutMargins {
                cell.contentView.layoutMargins = layoutMargins
            }
            cell.titleLabel.apply(sizable: text, defaultFont: cell.titleLabel.font)
        }
    }

    open override func apply(theme: Theme, toView view: UICollectionReusableView) {
        super.apply(theme: theme, toView: view)

        if let cell = view as? LargeTextHeaderCollectionViewCell {
            cell.titleLabel.textColor = theme.color(forKey: .primaryText)
        }
    }
}

// MARK: - Chaining methods

extension LargeTextHeaderFormItem {

    @discardableResult
    public func text(_ text: StringSizable) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }
}
