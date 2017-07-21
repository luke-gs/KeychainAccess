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

private let optimizedCheckboxImage = preburnedImage(AssetManager.shared.image(forKey: .checkbox)!, with: unselectedTintColor)

private let optimizedRadioImage = preburnedImage(AssetManager.shared.image(forKey: .radioButton)!, with: unselectedTintColor)

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
            if selected == false && highlighted == false {
                switch self {
                case .checkbox: return optimizedCheckboxImage
                case .radio:    return optimizedRadioImage
                }
            }
            
            let imageKey: AssetManager.ImageKey
            switch self {
            case .checkbox: imageKey = selected ? .checkboxSelected    : .checkbox
            case .radio:    imageKey = selected ? .radioButtonSelected : .radioButton
            }
            return AssetManager.shared.image(forKey: imageKey)!
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
    
    override func commonInit() {
        super.commonInit()
        
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
    
    /// Calculates the minimum content width for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - style:             The option style.
    ///   - title:             The title details for sizing.
    ///   - subtitle:          The subtitle details for sizing.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns:             The minumum content width for the cell.
    open class func minimumContentWidth(withStyle style: OptionStyle, title: StringSizable?, subtitle: StringSizable? = nil, compatibleWith traitCollection: UITraitCollection, accessoryViewSize: CGSize = .zero) -> CGFloat {
        return super.minimumContentWidth(withTitle: title, subtitle: subtitle, compatibleWith: traitCollection, imageSize: style.image(selected: false, highlighted: false).size, accessoryViewSize: accessoryViewSize)
    }
    
    
    /// Calculates the minimum content height for a cell, considering the content details.
    ///
    /// - Parameters:
    ///   - style:             The option style.
    ///   - title:             The title details for sizing.
    ///   - subtitle:          The subtitle details for sizing.
    ///   - width:             The content width for the cell.
    ///   - traitCollection:   The trait collection to calculate for.
    ///   - labelSeparation:   The label vertical separation. The default is the standard separation.
    ///   - accessoryViewSize: The size for the accessory view, or `.zero`. The default is `.zero`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withStyle style: OptionStyle, title: StringSizable?, subtitle: StringSizable? = nil, inWidth width: CGFloat,
                                         compatibleWith traitCollection: UITraitCollection, labelSeparation: CGFloat = CellTitleSubtitleSeparation, accessoryViewSize: CGSize = .zero) -> CGFloat {
        return super.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: width, compatibleWith: traitCollection, imageSize: style.image(selected: false, highlighted: false).size, labelSeparation: labelSeparation, accessoryViewSize: accessoryViewSize)
    }
    
}
