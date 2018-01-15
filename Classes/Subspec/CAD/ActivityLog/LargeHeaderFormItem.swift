//
//  LargeHeaderFormItem.swift
//  MPOLKit
//
//  Created by Kyle May on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class LargeHeaderFormItem: BaseSupplementaryFormItem {
    
    public var text: String?
    
    public init() {
        super.init(viewType: LargeTextHeaderCollectionViewCell.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: LargeTextHeaderCollectionViewCell.defaultReuseIdentifier)
    }
    
    public convenience init(text: String?) {
        self.init()
        self.text = text
    }
    
    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        return LargeTextHeaderCollectionViewCell.minimumHeight
    }

    open override func configure(_ view: UICollectionReusableView) {
        if let cell = view as? LargeTextHeaderCollectionViewCell {
            cell.titleLabel.text = text
        }
    }
}
