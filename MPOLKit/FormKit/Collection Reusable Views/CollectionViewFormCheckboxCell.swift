//
//  CollectionViewFormCheckboxCell.swift
//  FormKit
//
//  Created by Rod Brown on 28/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


private var textContext = 1

/// A simple cell class containing a checkbox.
/// The checkbox's selection is determined by selection status of the cell.
open class CollectionViewFormCheckboxCell: CollectionViewFormCell {
    
    open class func minimumContentWidth(withTitle title: String?, font: UIFont) -> CGFloat {
        return ceil((title as NSString?)?.size(attributes: [NSFontAttributeName: font]).width ?? 0 + 30.0)
    }
    
    open class func mininumContentWidth(withTitle title: String?, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        return minimumContentWidth(withTitle: title, font: SelectableButton.font(compatibleWith: traitCollection))
    }
        
    
    open let textLabel = UILabel(frame: .zero)
    fileprivate let imageView = UIImageView(image: .checkbox)
    fileprivate var preparingForReuse: Bool = false
    
    /// The checkbox inset within the layout margins.
    /// The default is an inset of 10.0 at the left, and zero on all other sides.
    open var checkBoxInset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0) {
        didSet { if checkBoxInset != oldValue { setNeedsLayout() } }
    }
    
    /// The enabled appearance of the checkbox.
    /// When disabled, an alpha of 0.5 is applied to the check box and its text label.
    open var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }
            let alpha: CGFloat = isEnabled ? 1.0 : 0.5
            textLabel.alpha = alpha
            imageView.alpha = alpha
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        
        applyStandardFonts()
        textLabel.addObserverForContentSizeKeys(self, context: &textContext)
        
        contentView.addSubview(textLabel)
        contentView.addSubview(imageView)
        
        updateImageView()
    }
    
    deinit {
        textLabel.removeObserverForContentSizeKeys(self, context: &textContext)
    }
}


/// Overrides 
extension CollectionViewFormCheckboxCell {
    
    open override var isSelected: Bool {
        didSet { updateImageView() }
    }
    
    open override var isHighlighted: Bool {
        didSet { updateImageView() }
    }
    
    open override func prepareForReuse() {
        preparingForReuse = true
        super.prepareForReuse()
        applyStandardFonts()
        preparingForReuse = false
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentView = self.contentView
        let contentRect = contentView.bounds.insetBy(contentView.layoutMargins).insetBy(checkBoxInset)
        
        var imageViewFrame = imageView.frame
        imageViewFrame.origin.x = contentRect.minX
        imageViewFrame.origin.y = (((contentRect.size.height - imageViewFrame.size.height) / 2.0) + contentRect.minY).rounded(toScale: UIScreen.main.scale)
        if imageView.frame != imageViewFrame {
            imageView.frame = imageViewFrame
        }
        
        let textLabelSize = textLabel.sizeThatFits(CGSize(width: contentRect.size.width - 10.0 - imageViewFrame.size.width, height: contentRect.size.height))
        
        let textLabelFrame = CGRect(x: imageViewFrame.maxX + 10.0, y: (((contentRect.size.height - textLabelSize.height) / 2.0) + contentRect.minY).rounded(toScale: UIScreen.main.scale), width: textLabelSize.width, height: textLabelSize.height)
        if textLabel.frame != textLabelFrame {
            textLabel.frame = textLabelFrame
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}


/// Private methods
fileprivate extension CollectionViewFormCheckboxCell {
    
    func updateImageView() {
        let correctImage: UIImage
        
        if isSelected && !isHighlighted {
            correctImage = .checkboxSelected
            imageView.tintColor = nil
        } else {
            correctImage = .checkbox
            imageView.tintColor = isHighlighted ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
        }
        
        if imageView.image != correctImage {
            imageView.image = correctImage
            
            if preparingForReuse == false, let collectionView = self.collectionView {
                let pointInCollectionView = collectionView.convert(imageView.center, from: contentView)
                if collectionView.bounds.contains(pointInCollectionView) {
                    let animation = CATransition()
                    animation.type = kCATransitionFade
                    animation.duration = 0.10
                    imageView.layer.add(animation, forKey: "selection")
                }
            }
        }
    }
    
    func applyStandardFonts() {
        textLabel.font = SelectableButton.font(compatibleWith: traitCollection)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.minimumScaleFactor = 0.9
    }
    
}
