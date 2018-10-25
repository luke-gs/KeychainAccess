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

    public var dataSource: EventCardsViewModelable?
    public weak var delegate: EventCardsDelegate?

    public init() {
        super.init(cellType: CollectionViewFormEventCardsCell.self, reuseIdentifier: CollectionViewFormEventCardsCell.defaultReuseIdentifier)
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormEventCardsCell else { return }
        cell.dataSource = dataSource
        cell.delegate = delegate
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormEventCardsCell.intrinsicHeight
    }
}

public protocol EventCardsViewModelable: class {
    var eventsList: [EventListDisplayable]? { get }
    func eventCreationString(for displayable: EventListDisplayable) -> String?
    func eventLocationString(for displayable: EventListDisplayable) -> String?
}

public protocol EventCardsDelegate: class {
    func didSelectEvent(at index: Int)
}
