//
//  CollectionViewFormOptionCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/05/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


private var kvoContext = 1

private let unselectedTintColor = #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)

// MARK: - Optimized prerendered images.

// Heavy use of tinting re-renders the images for no reason at each use,
// which can be expensive at reuse when you know the base color.
// `CollectionViewFormOptionCell` already sets a base tint for the unselected
// state irresepective of system tint, so we can do a nice simple optimization
// here. This really speeds up cell loading and reuse.

private let optimizedCheckboxImage = preburnedImage(.checkbox, with: unselectedTintColor)

private let optimizedRadioImage = preburnedImage(.radioButton, with: unselectedTintColor)

private func preburnedImage(_ image: UIImage, with color: UIColor) -> UIImage {
    return UIGraphicsImageRenderer(size: image.size).image { _ in
        color.setFill()
        image.draw(at: .zero, blendMode: .colorBurn, alpha: 1.0)
    }
}


/// A simple cell class containing an option picker, either for a checkbox or a radio button.
/// The option selection is determined by selection status of the cell.
open class CollectionViewFormOptionCell: CollectionViewFormSubtitleCell {
    
    public enum OptionStyle {
        case checkbox
        case radio
        
        fileprivate func image(selected: Bool, highlighted: Bool) -> UIImage {
            switch self {
            case .checkbox: return selected ? .checkboxSelected    : highlighted ? .checkbox : optimizedCheckboxImage
            case .radio:    return selected ? .radioButtonSelected : highlighted ? .radioButton : optimizedRadioImage
            }
        }
    }
    
    
    // MARK: - Properties
    
    open var optionStyle: OptionStyle = .checkbox {
        didSet { if optionStyle != oldValue { updateImageView() } }
    }
    
    
    /// The enabled appearance of the selection icon.
    /// When disabled, an alpha of 0.5 is applied to the cell content.
    open var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }
            contentView.alpha = isEnabled ? 1.0 : 0.5
            
            if isEnabled {
                accessibilityTraits |= UIAccessibilityTraitNotEnabled
            } else {
                accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
            }
        }
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel.font = SelectableButton.font(compatibleWith: traitCollection)
        titleLabel.minimumScaleFactor = 0.9
        updateImageView()
    }
    
    
    // MARK: - Overrides
    
    open override var isSelected: Bool {
        didSet { updateImageView() }
    }
    
    open override var isHighlighted: Bool {
        didSet { updateImageView() }
    }
    
    
    // MARK: - Private methods
    
    private func updateImageView() {
        imageView.image = optionStyle.image(selected: isSelected, highlighted: isHighlighted)
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the text and font details, with a standard option image.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - accessoryViewWidth: The width for the accessory view.
    /// - Returns:           The minumum content width for the cell.
    open class func minimumContentWidth(withStyle style: OptionStyle, title: String?, subtitle: String? = nil, compatibleWith traitCollection: UITraitCollection,
                                        titleFont: UIFont? = nil, subtitleFont: UIFont? = nil, singleLineTitle: Bool = true, singleLineSubtitle: Bool = true, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
        let titleTextFont = titleFont ?? SelectableButton.font(compatibleWith: traitCollection)
        return super.minimumContentWidth(withTitle: title, subtitle: subtitle, compatibleWith: traitCollection, image: style.image(selected: false, highlighted: true), titleFont: titleTextFont, subtitleFont: subtitleFont, singleLineTitle: singleLineTitle, singleLineSubtitle: singleLineSubtitle, accessoryViewWidth: accessoryViewWidth)
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details, with a standard selection image.
    ///
    /// - Parameters:
    ///   - style:           The cell selection style.
    ///   - title:           The title text.
    ///   - width:           The width constraint.
    ///   - traitCollection: The trait collection the cell will be displayed in.
    ///   - titleFont:       The title font.
    ///   - singleLineTitle: The default is `nil`, indicating the calculation should use the default.
    /// - Returns:           The minumum content height for the cell.
    open class func minimumContentHeight(withStyle style: OptionStyle, title: String?, subtitle: String? = nil, inWidth width: CGFloat,
                                         compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineSubtitle: Bool = true, labelSeparation: CGFloat = CellTitleSubtitleSeparation) -> CGFloat {
        return super.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: width, compatibleWith: traitCollection, image: style.image(selected: false, highlighted: true),
                                          titleFont: titleFont ?? SelectableButton.font(compatibleWith: traitCollection), subtitleFont: subtitleFont, singleLineTitle: singleLineTitle, singleLineSubtitle: singleLineSubtitle, labelSeparation: labelSeparation)
    }
    
}
