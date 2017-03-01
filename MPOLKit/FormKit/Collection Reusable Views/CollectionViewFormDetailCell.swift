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
        case title
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
    open var emphasis: Emphasis = .title {
        didSet { if emphasis != oldValue { applyStandardFonts() } }
    }
    
    
    /// The accessory view for the cell.
    ///
    /// This will be placed at the trailing edge of the cell.
    open var accessoryView: UIView? {
        didSet {
            if accessoryView == oldValue { return }
            
            oldValue?.removeFromSuperview()
            
            var newConstraints: [NSLayoutConstraint] = []
            if let newAccessoryView = accessoryView {
                contentView.addSubview(newAccessoryView)
                newAccessoryView.translatesAutoresizingMaskIntoConstraints = false
                
                textTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: newAccessoryView, attribute: .leading, constant: -10.0)
                newConstraints.append(NSLayoutConstraint(item: newAccessoryView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY))
                newConstraints.append(NSLayoutConstraint(item: newAccessoryView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top))
                newConstraints.append(NSLayoutConstraint(item: newAccessoryView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin))
            } else {
                textTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin)
            }
            newConstraints.append(textTrailingConstraint)
            NSLayoutConstraint.activate(newConstraints)
        }
    }
    
    
    // MARK: - Private properties
    
    fileprivate let textLayoutGuide = UILayoutGuide()
    
    fileprivate var titleDetailConstraint: NSLayoutConstraint!
    
    fileprivate var textLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var textTrailingConstraint: NSLayoutConstraint!
    
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
        
        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        contentView.addLayoutGuide(contentModeLayoutGuide)
        
        imageView.isHidden = true
        textLabel.isHidden = true
        detailTextLabel.isHidden = true
        
        detailTextLabel.numberOfLines = 0
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        imageWidthConstraint   = NSLayoutConstraint(item: imageView,       attribute: .width,    relatedBy: .equal, toConstant: 0.0, priority: UILayoutPriorityRequired - 1)
        titleDetailConstraint  = NSLayoutConstraint(item: detailTextLabel, attribute: .top,      relatedBy: .equal, toItem: textLabel, attribute: .bottom)
        textLeadingConstraint  = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: imageView, attribute: .trailing)
        textTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            imageWidthConstraint,
            
            NSLayoutConstraint(item: textLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: detailTextLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: detailTextLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailTextLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            textLeadingConstraint,
            textTrailingConstraint,
            titleDetailConstraint,
            
            NSLayoutConstraint(item: imageView,       attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow)
        ])
        
        let textKeyPath = #keyPath(UILabel.text)
        textLabel.addObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        detailTextLabel.addObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
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
                titleDetailConstraint.constant = (textLabel.text?.isEmpty ?? true || detailTextLabel.text?.isEmpty ?? true) ? 0.0 : 2.0
            case let imageView as UIImageView:
                let imageSize = imageView.image?.size
                imageView.isHidden = imageSize?.isEmpty ?? true
                textLeadingConstraint.constant = imageSize?.isEmpty ?? true ? 0.0 : 10.0
                imageWidthConstraint.constant = imageSize?.width ?? 0.0
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}


internal extension CollectionViewFormDetailCell {
    
    internal class func font(withEmphasis emphasis: Bool, compatibleWith traitCollection: UITraitCollection) -> UIFont {
        return .preferredFont(forTextStyle: emphasis ? .headline : .footnote, compatibleWith: traitCollection)
    }
    
    internal override func applyStandardFonts() {
        let traitCollection = self.traitCollection
        textLabel.font       = type(of: self).font(withEmphasis: emphasis == .title,   compatibleWith: traitCollection)
        detailTextLabel.font = type(of: self).font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        textLabel.adjustsFontForContentSizeCategory       = true
        detailTextLabel.adjustsFontForContentSizeCategory = true
    }
    
}

// MARK: - Cell Sizing
/// Cell sizing
extension CollectionViewFormDetailCell {
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:      The title text for the cell.
    ///   - detail:     The detail text for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image:      The leading image for the cell. The default is `nil`.
    ///   - emphasis:   The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont:  The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:  A boolean value indicating if the detail text should be constrained to a single line. The default is `true`.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content width for the cell.
    open class func minimumContentWidth(forTitle title: String?, detail: String?, compatibleWith traitCollection: UITraitCollection, image: UIImage? = nil,
                                        emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineDetail: Bool = false) -> CGFloat {
        let titleTextFont  = titleFont  ?? font(withEmphasis: emphasis == .title, compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace)
            imageSpace += 10.0
        }
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        let detailWidth = (detail as NSString?)?.boundingRect(with: .max, options: singleLineDetail ? [] : .usesLineFragmentOrigin,
                                                              attributes: [NSFontAttributeName: detailTextFont],
                                                              context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleWidth, detailWidth) + imageSpace
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:      The title text for the cell.
    ///   - detail:     The detail text for the cell.
    ///   - width:      The width constraint for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image:      The leading image for the cell. The default is `nil`.
    ///   - emphasis:   The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont:  The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(forTitle title: String?, detail: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineDetail: Bool = false) -> CGFloat {
        let titleTextFont  = titleFont  ?? font(withEmphasis: emphasis == .title,   compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let textHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        
        let detailHeight = (detail as NSString?)?.boundingRect(with: size, options: singleLineDetail ? [] : .usesLineFragmentOrigin,
                                                               attributes: [NSFontAttributeName: detailTextFont],
                                                               context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        var combinedHeight = textHeight + detailHeight
        if textHeight !=~ 0.0 && detailHeight !=~ 0.0 {
            combinedHeight += CellTitleDetailSeparation
        }
        
        return combinedHeight
    }
    
}

