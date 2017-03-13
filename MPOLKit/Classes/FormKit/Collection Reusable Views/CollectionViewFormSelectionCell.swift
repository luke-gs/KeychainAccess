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
            
            if isEnabled {
                accessibilityTraits += UIAccessibilityTraitNotEnabled
            } else {
                accessibilityTraits -= UIAccessibilityTraitNotEnabled
            }
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
    
    internal override func applyStandardFonts() {
        textLabel.font = SelectableButton.font(compatibleWith: traitCollection)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.minimumScaleFactor = 0.9
    }
    
}


// MARK: - Sizing
/// Sizing
extension CollectionViewFormSelectionCell {
    
    /// Calculates the minimum content width for a cell, considering the text and font details, with a standard selection image.
    ///
    /// - Parameters:
    ///   - title:            The title text for the cell.
    ///   - detail:           The detail text for the cell.
    ///   - traitCollection:  The trait collection the cell will be deisplayed in.
    ///   - emphasis:         The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont:        The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont:       The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:  A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, detail: String?, compatibleWith traitCollection: UITraitCollection,
                                        emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineDetail: Bool = false) -> CGFloat {
        return super.minimumContentWidth(withTitle: title, detail: detail, compatibleWith: traitCollection, image: .checkbox,
                                         emphasis: emphasis, titleFont: titleFont, detailFont: detailFont,
                                         singleLineTitle: singleLineTitle, singleLineDetail: singleLineDetail)
    }
    
    /// Calculates the minimum content height for a cell, considering the text and font details, with a standard selection image
    ///
    /// - Parameters:
    ///   - title:            The title text for the cell.
    ///   - detail:           The detail text for the cell.
    ///   - width:            The width constraint for the cell.
    ///   - traitCollection:  The trait collection the cell will be deisplayed in.
    ///   - emphasis:         The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont:        The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont:       The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:  A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: String?, detail: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineDetail: Bool = false) -> CGFloat {
        return super.minimumContentHeight(withTitle: title, detail: detail, inWidth: width, compatibleWith: traitCollection, image: .checkbox,
                                          emphasis: emphasis, titleFont: titleFont, detailFont: detailFont,
                                          singleLineTitle: singleLineTitle, singleLineDetail: singleLineDetail)
    }
    
    internal override class func font(withEmphasis emphasis: Bool, compatibleWith traitCollection: UITraitCollection) -> UIFont {
        return emphasis ? SelectableButton.font(compatibleWith: traitCollection) : super.font(withEmphasis: emphasis, compatibleWith: traitCollection)
    }
    
}


// MARK: - Private methods
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
