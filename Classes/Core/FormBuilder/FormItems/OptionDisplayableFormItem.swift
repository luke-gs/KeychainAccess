//
//  OptionDisplayableFormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class OptionDisplayableFormItem: BaseFormItem {

    public var options: [OptionDisplayable] = []

    private var selectedIndex: Int?
    private var selectionHandler: ((Int) -> ())?

    private init() {
        super.init(cellType: CollectionViewFormOptionStackViewCell.self, reuseIdentifier: CollectionViewFormOptionStackViewCell.defaultReuseIdentifier)
    }

    public convenience init(options: [OptionDisplayable]) {
        self.init()
        self.options = options
    }

    public override func configure(_ cell: CollectionViewFormCell) {

        guard let cell = cell as? CollectionViewFormOptionStackViewCell else {
            fatalError("Failed to cast cell as option stack view cell")
        }

        cell.setOptions(options)

        cell.selectionHandler = { index in
            self.selectionHandler?(index)
        }

        if let value = selectedIndex {
            cell.setSelectedOption(indexOfSelectedCell: value)
        }
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {

        var maxHeight = options.reduce(0) { (result, option) -> CGFloat in
            return max(result, option.image.size.height)
        }

        //spacing for the cell
        let spacing: CGFloat = 60

        let text = options.first?.title ?? ""

        let textHeight = text.sizing(defaultNumberOfLines: 1,
                                     defaultFont: .preferredFont(forTextStyle: .body,
                                                                 compatibleWith: traitCollection)).minimumHeight(inWidth: contentWidth,
                                                                                                                 compatibleWith: traitCollection)
        maxHeight += spacing + textHeight

        return maxHeight
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }
}


extension OptionDisplayableFormItem {

    public func selectionHandler(_ handler: @escaping (Int) -> ()) -> Self {
        self.selectionHandler = handler
        return self
    }

    public func selectedIndex(_ value: Int?) -> Self {
        self.selectedIndex = value
        return self
    }
}
