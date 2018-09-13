//
//  TrafficHistoryOverviewFormItem.swift
//  ClientKit
//
//  Created by Megan Efron on 12/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public class TrafficHistoryOverviewFormItem: BaseFormItem {
    
    // MARK: - Detail properties
    
    public var items: [TrafficHistoryCollectionViewCell.Item] = []
    
    public var text: StringSizable?
    
    // MARK: - Initializers
    
    public init() {
        super.init(cellType: TrafficHistoryCollectionViewCell.self, reuseIdentifier: TrafficHistoryCollectionViewCell.defaultReuseIdentifier)
    }
    
    public convenience init(text: StringSizable? = nil, items: [TrafficHistoryCollectionViewCell.Item] = []) {
        self.init()
        
        self.text = text
        self.items = items
    }
    
    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! TrafficHistoryCollectionViewCell
        
        cell.label.apply(sizable: text, defaultFont: UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
        cell.details = items
        cell.separatorStyle = .none
    }
    
    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }
    
    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return TrafficHistoryCollectionViewCell.minimumContentHeight(withDetail: text, inWidth: contentWidth, compatibleWith: traitCollection)
    }
    
    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let cell = cell as! TrafficHistoryCollectionViewCell
        cell.applyTheme(theme: theme)
    }

}

// MARK: - Chaining methods

extension TrafficHistoryOverviewFormItem {
    
    @discardableResult
    public func text(_ text: StringSizable?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    public func items(_ items: [TrafficHistoryCollectionViewCell.Item]) -> Self {
        self.items = items
        return self
    }
}
