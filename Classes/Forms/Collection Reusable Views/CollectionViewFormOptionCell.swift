//
//  CollectionViewFormOptionCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/05/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


private var textContext = 1

/// A simple cell class containing an option picker, either for a checkbox or a radio button.
/// The checkbox's selection is determined by selection status of the cell.
open class CollectionViewFormOptionCell: CollectionViewFormCell {
    
    public enum OptionStyle {
        case checkbox
        case radio
        
        func image(selected: Bool) -> UIImage {
            switch self {
            case .checkbox: return selected ? .checkboxSelected    : .checkbox
            case .radio:    return selected ? .radioButtonSelected : .radioButton
            }
        }
    }
    
    
    // MARK: - Properties
    
    open var optionStyle: OptionStyle = .checkbox {
        didSet { if optionStyle != oldValue { updateImageView() } }
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
    
    private let imageView: UIImageView = UIImageView(frame: .zero)
    
    
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
        let contentView   = self.contentView
        let imageView     = self.imageView
        let titleLabel    = self.titleLabel
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: imageView, attribute: .trailing, constant: 10.0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
        ])
        
        updateImageView()
    }
    
    
    // MARK: - Overrides
    
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
    
    
    // MARK: - Private methods
    
    private func updateImageView() {
        let isSelected    = self.isSelected
        let isHighlighted = self.isHighlighted
        
        imageView.image = optionStyle.image(selected: isSelected)
        imageView.tintColor = isSelected || isHighlighted ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
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
    open class func minimumContentWidth(withStyle style: OptionStyle, title: String?, compatibleWith traitCollection: UITraitCollection,
                                        titleFont: UIFont? = nil, singleLineTitle: Bool = true, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
        let titleTextFont = titleFont ?? SelectableButton.font(compatibleWith: traitCollection)
        let imageSize = style.image(selected: false).size
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: traitCollection.currentDisplayScale) ?? 0.0
        return titleWidth + imageSize.width + 10.0 + (accessoryViewWidth > 0.00001 ? accessoryViewWidth + 10.0 : 0.0)
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
    open class func minimumContentHeight(withStyle style: OptionStyle, title: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         titleFont: UIFont? = nil, singleLineTitle: Bool = true) -> CGFloat {
        let titleTextFont = titleFont ?? SelectableButton.font(compatibleWith: traitCollection)
        let imageSize = style.image(selected: false).size
        
        
        let size = CGSize(width: width - imageSize.width - 10.0, height: CGFloat.greatestFiniteMagnitude)
        
        let titleHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: titleTextFont],
                                                             context: nil).height.ceiled(toScale: traitCollection.currentDisplayScale) ?? 0.0
        
        return max(titleHeight, imageSize.height)
    }
    
}
