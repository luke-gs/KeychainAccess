//
//  RoundedRectButtonFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Form item for a centred `RoundedRectButton`
open class RoundedRectButtonFormItem: BaseFormItem {
    private var title: StringSizing?
    private var edgeInsets: UIEdgeInsets?
    private var radius: CGFloat?
    
    public init() {
        super.init(cellType: CollectionViewFormRoundedRectButtonCell.self, reuseIdentifier: CollectionViewFormRoundedRectButtonCell.defaultReuseIdentifier)
    }
    
    open override func configure(_ cell: CollectionViewFormCell) {
        if let cell = cell as? CollectionViewFormRoundedRectButtonCell {
            cell.button.setTitle(title?.string, for: .normal)
            cell.button.titleLabel?.font = title?.font
            if let edgeInsets = edgeInsets {
                cell.button.contentEdgeInsets = edgeInsets
            }
            if let radius = radius {
                cell.button.layer.cornerRadius = radius
            }
            
            cell.button.addTarget(self, action: #selector(didTapButton(_:)), for: .primaryActionTriggered)
        }
    }
    
    open override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }
    
    open override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        let insets = edgeInsets ?? RoundedRectButton.defaultInsets
        let stringHeight = title?.sizing().minimumHeight(inWidth: contentWidth, compatibleWith: traitCollection) ?? 0
        return stringHeight + insets.top + insets.bottom
    }
    
    @discardableResult
    public func title(_ title: StringSizing) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func edgeInsets(_ edgeInsets: UIEdgeInsets) -> Self {
        self.edgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ radius: CGFloat) -> Self {
        self.radius = radius
        return self
    }
    
    @objc private func didTapButton(_ button: UIButton) {
        guard let cell = cell else { return }
        onSelection?(cell)
    }
}
