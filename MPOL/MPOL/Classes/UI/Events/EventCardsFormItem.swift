//
//  EventCardsFormItem.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class EventCardsFormItem: BaseFormItem {

    public init() {
        super.init(cellType: CollectionViewFormEventCardsCell.self, reuseIdentifier: CollectionViewFormEventCardsCell.defaultReuseIdentifier)
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormEventCardsCell else { return }
        //Configure cell here
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormEventCardsCell.intrinsicHeight
    }
}
