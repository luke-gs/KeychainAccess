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
open class CollectionViewFormSelectionCell: CollectionViewFormDetailCell {
    
    
    open class func mininumContentWidth(withTitle title: String?, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        return minimumContentWidth(withTitle: title, font: SelectableButton.font(compatibleWith: traitCollection))
    }
    
    open class func minimumContentWidth(withTitle title: String?, font: UIFont) -> CGFloat {
        return ceil((title as NSString?)?.size(attributes: [NSFontAttributeName: font]).width ?? 0 + 30.0)
    }
    
    open class func minimumContentHeight(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        return minimumContentHeight(withTitleFont: SelectableButton.font(compatibleWith: traitCollection))
    }
    
    open class func minimumContentHeight(withTitleFont titleFont: UIFont) -> CGFloat {
        return super.minimumContentHeight(forText: "Kj", detailText: nil, inWidth: .greatestFiniteMagnitude, compatibleWith: nil, image: .checkbox, emphasis: .text, titleFont: titleFont, detailFont: nil, singleLineDetail: true)
    }
    
    
    public enum SelectionStyle {
        case checkbox
        case radio
    }
    
    
    open var selectionStyle: SelectionStyle = .checkbox {
        didSet { if selectionStyle != oldValue { updateImageView() } }
    }
    
    
    /// The enabled appearance of the selection icon.
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
        updateImageView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateImageView()
    }
    
}


/// Overrides 
extension CollectionViewFormSelectionCell {
    
    open override var isSelected: Bool {
        didSet { updateImageView() }
    }
    
    open override var isHighlighted: Bool {
        didSet { updateImageView() }
    }
    
}

internal extension CollectionViewFormSelectionCell {
    
    internal override func applyStandardFonts() {
        textLabel.font = SelectableButton.font(compatibleWith: traitCollection)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.minimumScaleFactor = 0.9
    }
    
}



/// Private methods
fileprivate extension CollectionViewFormSelectionCell {
    
    func updateImageView() {
        let correctImage: UIImage
        
        switch selectionStyle {
        case .checkbox:
            if isSelected && !isHighlighted {
                correctImage = .checkboxSelected
                imageView.tintColor = nil
            } else {
                correctImage = .checkbox
                imageView.tintColor = isHighlighted ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
            }
        case .radio:
            if isSelected && !isHighlighted {
                correctImage = .radioButtonSelected
                imageView.tintColor = nil
            } else {
                correctImage = .radioButton
                imageView.tintColor = isHighlighted ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
            }
        }
        
        if imageView.image != correctImage {
            imageView.image = correctImage
        }
    }
    
}
