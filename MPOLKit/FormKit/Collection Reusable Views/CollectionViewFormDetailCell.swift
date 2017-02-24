//
//  CollectionViewFormDetailCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

fileprivate var contentContext = 1

open class CollectionViewFormDetailCell: CollectionViewFormCell {
    
    public enum Emphasis {
        case text
        case detail
    }
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let textLabel       = UILabel(frame: .zero)
    
    
    /// The detail text label for the cell.
    public let detailTextLabel = UILabel(frame: .zero)
    
    
    /// The image view for the cell.
    public let imageView = UIImageView(frame: .zero)
    
    
    /// The emphasized element within the cell. The emphasized item will be highlighted
    ///  with stronger default fonts.
    ///
    /// Setting this property re-sets the label fonts to default
    open var emphasis: Emphasis = .text {
        didSet { if emphasis != oldValue { applyStandardFonts() } }
    }
    
    
    /// The accessory view for the cell.
    ///
    /// This will be placed at the trailing edge of the cell.
    open var accessoryView: UIView? {
        didSet {
            if accessoryView == oldValue { return }
            
            oldValue?.removeFromSuperview()
            if let newAccessoryView = accessoryView {
                contentView.addSubview(newAccessoryView)
                textLabelTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: newAccessoryView, attribute: .leading, constant: -10.0)
            } else {
                textLabelTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView.layoutMarginsGuide, attribute: .trailing)
            }
            textLabelTrailingConstraint.isActive = true
        }
    }
    
    
    /// The content mode for the cell.
    /// This causes the cell to re-layout its content with the requested content parameters,
    /// in the vertical dimension.
    /// - note: Currently supports only .Top or .Center
    open override var contentMode: UIViewContentMode {
        didSet {
            let newContentModeIsTop = contentMode == .top
            let oldContentModeIsTop = oldValue == .top
            
            if oldContentModeIsTop != newContentModeIsTop {
                textLabelYConstraint.isActive = false
                let attribute: NSLayoutAttribute = newContentModeIsTop ? .top : .centerY
                textLabelYConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: attribute, relatedBy: .equal, toItem: contentView.layoutMarginsGuide, attribute: attribute)
                textLabelYConstraint.isActive = true
            }
        
        }
    }
    
    
    // MARK: - Private properties
    
    fileprivate static var interLabelSeparation: CGFloat = 3.0
    
    internal var imageViewYConstraint: NSLayoutConstraint!
    
    fileprivate let textLayoutGuide = UILayoutGuide()
    
    fileprivate var interLabelConstraint: NSLayoutConstraint!
    
    fileprivate var textLabelLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var textLabelTrailingConstraint: NSLayoutConstraint!
    
    fileprivate var textLabelYConstraint: NSLayoutConstraint!
    
    fileprivate var imageWidthConstraint: NSLayoutConstraint!
    
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        super.contentMode = .center
        
        let contentView     = self.contentView
        let textLabel       = self.textLabel
        let detailTextLabel = self.detailTextLabel
        let imageView       = self.imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(detailTextLabel)
        contentView.addSubview(textLabel)
        contentView.addSubview(imageView)
        contentView.addLayoutGuide(textLayoutGuide)
        
        imageView.isHidden = true
        textLabel.isHidden = true
        detailTextLabel.isHidden = true
        
        let contentLayoutGuide = contentView.layoutMarginsGuide
        
        imageWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toConstant: 0.0, priority: UILayoutPriorityRequired - 1)
        interLabelConstraint = NSLayoutConstraint(item: detailTextLabel, attribute: .top, relatedBy: .equal, toItem: textLabel, attribute: .bottom)
        textLabelLeadingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing)
        textLabelTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentLayoutGuide, attribute: .trailing)
        
        textLabelYConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: contentLayoutGuide, attribute: .centerY)
        imageViewYConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: textLayoutGuide, attribute: .centerY)
        
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentLayoutGuide, attribute: .leading),
            
            NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: detailTextLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: detailTextLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailTextLabel, attribute: .bottom, relatedBy: .equal, toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentLayoutGuide, attribute: .trailing),
            
            textLabelLeadingConstraint, textLabelTrailingConstraint, textLabelYConstraint,
            interLabelConstraint, imageWidthConstraint, imageViewYConstraint
        ])
        
        let textKeyPath = #keyPath(UILabel.text)
        textLabel.addObserver(self, forKeyPath: textKeyPath, options: [], context: &contentContext)
        detailTextLabel.addObserver(self, forKeyPath: textKeyPath, options: [], context: &contentContext)
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), options: [], context: &contentContext)
    }
   
    deinit {
        let textKeyPath = #keyPath(UILabel.text)
        textLabel.removeObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        detailTextLabel.removeObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
    }
    
}



// MARK: - Overrides
/// Overrides
extension CollectionViewFormDetailCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
                interLabelConstraint.constant = (textLabel.text?.isEmpty ?? true || detailTextLabel.text?.isEmpty ?? true) ? 0.0 : 2.0
            case let imageView as UIImageView:
                let imageSize = imageView.image?.size
                imageView.isHidden = imageSize?.isEmpty ?? true
                textLabelLeadingConstraint.constant = imageSize?.isEmpty ?? true ? 0.0 : 10.0
                imageWidthConstraint.constant = imageSize?.width ?? 0.0
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func layoutSubviews() {
        let startTime = CFAbsoluteTimeGetCurrent()
        super.layoutSubviews()
        print("Layout Time Taken: \(CFAbsoluteTimeGetCurrent() - startTime)")
    }
    
}


internal extension CollectionViewFormDetailCell {
    
    internal class func font(withEmphasis emphasis: Bool, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        return .preferredFont(forTextStyle: emphasis ? .headline : .footnote, compatibleWith: traitCollection)
    }
    
    internal override func applyStandardFonts() {
        let traitCollection = self.traitCollection
        textLabel.font       = CollectionViewFormDetailCell.font(withEmphasis: emphasis == .text,   compatibleWith: traitCollection)
        detailTextLabel.font = CollectionViewFormDetailCell.font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        textLabel.adjustsFontForContentSizeCategory = true
        detailTextLabel.adjustsFontForContentSizeCategory = true
    }
    
}

// MARK: - Cell Sizing
/// Cell sizing
extension CollectionViewFormDetailCell {
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - text: The text for the cell.
    ///   - detailText: The detail text for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image: The leading image for the cell. The default is `nil`.
    ///   - emphasis: The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont: The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(forText text: String?, detailText: String?, compatibleWith traitCollection: UITraitCollection, image: UIImage? = nil,
                                        emphasis: Emphasis = .text, titleFont: UIFont? = nil, detailFont: UIFont? = nil, singleLineDetail: Bool = false) -> CGFloat {
        let textFont = titleFont ?? font(withEmphasis: emphasis == .text, compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace)
            imageSpace += 10.0
        }
        
        let textWidth = (text as NSString?)?.size(attributes: [NSFontAttributeName: textFont]).width ?? 0.0
        if let detailText = detailText {
            if singleLineDetail {
                let detailTextWidth = (detailText as NSString).size(attributes: [NSFontAttributeName: detailTextFont]).width
                return ceil(max(textWidth, detailTextWidth)) + imageSpace
            } else {
                return max(ceil(textWidth), 50.0) + imageSpace
            }
        }
        return ceil(textWidth) + imageSpace
    }
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - text: The text for the cell.
    ///   - detailText: The detail text for the cell.
    ///   - width:      The width constraint for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image: The leading image for the cell. The default is `nil`.
    ///   - emphasis: The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont: The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(forText text: String?, detailText: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection?,
                                         image: UIImage? = nil, emphasis: Emphasis = .text, titleFont: UIFont? = nil, detailFont: UIFont? = nil, singleLineDetail: Bool = false) -> CGFloat {
        let textFont       = titleFont  ?? font(withEmphasis: emphasis == .text,   compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        let textHeight = ((text ?? "") as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil).height
        let detailTextHeight = ((detailText ?? "") as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: singleLineDetail ? [] : .usesLineFragmentOrigin, attributes: [NSFontAttributeName: detailTextFont], context: nil).height
        let height = ceil(textHeight) + ceil(detailTextHeight) + 6.0
        return max(textHeight.isZero == false && detailTextHeight.isZero == false ? height + interLabelSeparation : height, image?.size.height ?? 0.0)
    }
    
}

