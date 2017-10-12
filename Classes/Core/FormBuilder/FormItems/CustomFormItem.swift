//
//  CustomFormItem.swift
//  Pods
//
//  Created by KGWH78 on 20/9/17.
//
//

import Foundation


/// Custom form item. Use this class to provide a single used cell. Specify the `onConfigured` handler to provide
/// the custom configuration the cell.
public final class CustomFormItem: BaseFormItem {

    public override func configure(_ cell: CollectionViewFormCell) { }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return 44.0
    }

}
