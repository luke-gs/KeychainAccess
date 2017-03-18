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
open class CollectionViewFormSelectionCell: CollectionViewFormCell {
    
    public enum SelectionStyle {
        case checkbox
        case radio
        
        func image(selected: Bool) -> UIImage {
            switch self {
            case .checkbox: return selected ? .checkboxSelected    : .checkbox
            case .radio:    return selected ? .radioButtonSelected : .radioButton
            }
        }
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
            titleLabel.alpha = alpha
            imageView.alpha = alpha
            
            if isEnabled {
                accessibilityTraits |= UIAccessibilityTraitNotEnabled
            } else {
                accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
            }
        }
    }
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    
    fileprivate let imageView: UIImageView = UIImageView(frame: .zero)
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
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
        super.applyStandardFonts()
        
        titleLabel.font = SelectableButton.font(compatibleWith: traitCollection)
        titleLabel.minimumScaleFactor = 0.9
    }
    
}


// MARK: - Sizing
/// Sizing
extension CollectionViewFormSelectionCell {
    
    /// Calculates the minimum content width for a cell, considering the text and font details, with a standard selection image.
    ///
    /// - Parameters:
    ///   - title:
    ///   - detail:           The detail text for the cell.
    ///   - traitCollection:
    ///   - emphasis:         The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont:
    ///   - detailFont:       The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:  A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content width for the cell.
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details, with a standard selection image.
    ///
    /// - Parameters:
    ///   - title:           The title text for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - titleFont:       The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle: A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    /// - Returns:           The minumum content width for the cell.
    open class func minimumContentWidth(withStyle style: SelectionStyle, title: String?, compatibleWith traitCollection: UITraitCollection,
                                        titleFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        let titleTextFont = titleFont ?? SelectableButton.font(compatibleWith: traitCollection)
        let imageSize = style.image(selected: false).size
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        return titleWidth + imageSize.width + 10.0
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
    open class func minimumContentHeight(withStyle style: SelectionStyle, title: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         titleFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        let titleTextFont = titleFont ?? SelectableButton.font(compatibleWith: traitCollection)
        let imageSize = style.image(selected: false).size
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let size = CGSize(width: width - imageSize.width - 10.0, height: CGFloat.greatestFiniteMagnitude)
        
        let titleHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: titleTextFont],
                                                             context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleHeight, imageSize.height)
    }
    
}


// MARK: - Private methods
/// Private methods
fileprivate extension CollectionViewFormSelectionCell {
    
    func updateImageView() {
        let isSelected    = self.isSelected
        let isHighlighted = self.isHighlighted

        imageView.image = selectionStyle.image(selected: isSelected)
        imageView.tintColor = isSelected || isHighlighted ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
    }
    
}
