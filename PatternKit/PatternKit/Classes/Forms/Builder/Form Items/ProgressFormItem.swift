//
//  ProgressFormItem.swift
//  MPOLKit
//
//  Created by Megan Efron on 8/11/17.
//

import Foundation

public class ProgressFormItem: BaseFormItem  {
    
    public var title: StringSizable?
    
    public var value: StringSizable?
    
    public var detail: StringSizable?
    
    public var image: UIImage?
    
    public var progress: Float = 0
    
    public var isProgressHidden: Bool = false
    
    public var progressTintColor: UIColor?
    
    public var imageSeparation: CGFloat = CellImageLabelSeparation
    
    public var labelSeparation: CGFloat = CellTitleSubtitleSeparation

    public init() {
        super.init(cellType: CollectionViewFormProgressCell.self, reuseIdentifier: CollectionViewFormProgressCell.defaultReuseIdentifier)
    }
    
    public convenience init(title: StringSizable? = nil, value: StringSizable? = nil, detail: StringSizable? = nil, image: UIImage? = nil, progress: Float = 0, progressTintColor: UIColor? = nil) {
        self.init()
        
        self.title = title
        self.value = value
        self.detail = detail
        self.image = image
        self.progress = progress
        self.progressTintColor = progressTintColor
    }
    
    public override func configure(_ cell: CollectionViewFormCell) {
        let cell = cell as! CollectionViewFormProgressCell
        
        cell.isEditable = false
        
        cell.titleLabel.apply(sizable: title, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
        cell.valueLabel.apply(sizable: value, defaultFont: .preferredFont(forTextStyle: .headline, compatibleWith: cell.traitCollection))
        cell.textLabel.apply(sizable: detail, defaultFont: .preferredFont(forTextStyle: .footnote, compatibleWith: cell.traitCollection))
        
        cell.imageView.image = image
        
        cell.isProgressHidden = isProgressHidden
        cell.progressView.progress = progress
        cell.progressView.progressTintColor = progressTintColor
    }
    
    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        
        return CollectionViewFormProgressCell.minimumContentHeight(withTitle: title, value: value, placeholder: nil, inWidth: contentWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: imageSeparation, labelSeparation: labelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }
    
    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormProgressCell.minimumContentWidth(withTitle: title, value: value, placeholder: nil, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, imageSeparation: CellImageLabelSeparation, accessoryViewSize: accessory?.size ?? .zero)
    }
    
    public override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        
        let cell = cell as! CollectionViewFormProgressCell
        
        cell.titleLabel.textColor = secondaryTextColor
        cell.valueLabel.textColor = secondaryTextColor
        cell.textLabel.textColor = secondaryTextColor
    }
}

// MARK: - Chaining methods

extension ProgressFormItem {
    
    @discardableResult
    public func title(_ title: StringSizable?) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func value(_ value: StringSizable?) -> Self {
        self.value = value
        return self
    }
    
    @discardableResult
    public func detail(_ detail: StringSizable?) -> Self {
        self.detail = detail
        return self
    }
    
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    @discardableResult
    public func progress(_ progress: Float) -> Self {
        self.progress = progress
        return self
    }
    
    @discardableResult
    public func isProgressHidden(_ isProgressHidden: Bool) -> Self {
        self.isProgressHidden = isProgressHidden
        return self
    }
    
    @discardableResult
    public func progressTintColor(_ progressTintColor: UIColor?) -> Self {
        self.progressTintColor = progressTintColor
        return self
    }
    
    @discardableResult
    public func imageSeparation(_ separation: CGFloat) -> Self {
        self.imageSeparation = separation
        return self
    }
    
    @discardableResult
    public func labelSeparation(_ separation: CGFloat) -> Self {
        self.labelSeparation = separation
        return self
    }
    
}
