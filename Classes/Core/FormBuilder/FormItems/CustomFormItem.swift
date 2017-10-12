//
//  CustomFormItem.swift
//  Pods
//
//  Created by KGWH78 on 20/9/17.
//
//

import Foundation


public final class CustomFormItem<T: CollectionViewFormCell>: CollectionViewFormItem {

    public init(cellType: T.Type, reuseIdentifier: String) {
        super.init(cellType: cellType, reuseIdentifier: reuseIdentifier)
    }

    public override func configure(_ cell: CollectionViewFormCell) { }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return 44.0
    }

}
