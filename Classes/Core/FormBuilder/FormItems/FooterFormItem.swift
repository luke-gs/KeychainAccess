//
//  FooterFormItem.swift
//  MPOLKit
//
//  Created by KGWH78 on 27/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class FooterFormItem: BaseSupplementaryFormItem {

    public var text: String?

    public init() {
        super.init(viewType: CollectionViewFormFooterView.self, kind: UICollectionElementKindSectionFooter, reuseIdentifier: CollectionViewFormFooterView.defaultReuseIdentifier)
    }

    public convenience init(text: String?) {
        self.init()

        self.text = text
    }

    public override func configure(_ view: UIView) {
        let view = view as! CollectionViewFormFooterView

        view.text = text
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormFooterView.minimumHeight
    }

    public override func apply(theme: Theme, toView view: UICollectionReusableView) {
        let view = view as! CollectionViewFormFooterView

        let secondaryTextColor = theme.color(forKey: .secondaryText)
        view.tintColor = secondaryTextColor
    }

}

// MARK: - Chaining methods

extension FooterFormItem {

    @discardableResult
    public func text(_ text: String?) -> Self {
        self.text = text
        return self
    }

}
