//
//  CollectionViewFormSubtitleCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

fileprivate var contentContext = 1

open class CollectionViewFormSubtitleCell: CollectionViewFormCell {
    
    public enum Emphasis {
        case title
        case subtitle
    }
    
    // MARK: - Public properties
    
    /// The text label for the cell.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The subtitle text label for the cell.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The image view for the cell.
    public let imageView: UIImageView = UIImageView(frame: .zero)
    
    
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
    
    /// A boolean value indicating to MPOL applications that the cell represents an editable
    /// field. This variable is exposed via the additional MPOL property `isEditableField`,
    /// and should be ignored when the cell is "title-emphasised".
    ///
    /// The default is `true`.
    internal var mpol_isEditableField: Bool = true
    
    fileprivate let textLayoutGuide = UILayoutGuide()
    
    fileprivate var titleSubtitleConstraint: NSLayoutConstraint!
    
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
        
        accessibilityTraits |= UIAccessibilityTraitStaticText
        
        let contentView   = self.contentView
        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        let imageView     = self.imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        contentView.addLayoutGuide(contentModeLayoutGuide)
        
        imageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        
        subtitleLabel.numberOfLines = 0
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        imageWidthConstraint   = NSLayoutConstraint(item: imageView,       attribute: .width,    relatedBy: .equal, toConstant: 0.0, priority: UILayoutPriorityRequired - 1)
        titleSubtitleConstraint  = NSLayoutConstraint(item: subtitleLabel, attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        textLeadingConstraint  = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: imageView, attribute: .trailing)
        textTrailingConstraint = NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            imageWidthConstraint,
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            textLeadingConstraint,
            textTrailingConstraint,
            titleSubtitleConstraint,
            
            NSLayoutConstraint(item: imageView,       attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow)
        ])
        
        let textKeyPath = #keyPath(UILabel.text)
        titleLabel.addObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        subtitleLabel.addObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
    }
   
    deinit {
        let textKeyPath = #keyPath(UILabel.text)
        titleLabel.removeObserver(self,    forKeyPath: textKeyPath, context: &contentContext)
        subtitleLabel.removeObserver(self, forKeyPath: textKeyPath, context: &contentContext)
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
    }
    
}



// MARK: - Overrides
/// Overrides
extension CollectionViewFormSubtitleCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
                titleSubtitleConstraint.constant = (titleLabel.text?.isEmpty ?? true || subtitleLabel.text?.isEmpty ?? true) ? 0.0 : CellTitleSubtitleSeparation
            case let imageView as UIImageView:
                let imageSize = imageView.image?.size
                imageView.isHidden             = imageSize?.isEmpty ?? true
                textLeadingConstraint.constant = imageSize?.isEmpty ?? true ? 0.0 : 10.0
                imageWidthConstraint.constant  = imageSize?.width ?? 0.0
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    dynamic open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return [titleLabel, subtitleLabel].flatMap({ $0.text }).joined(separator: ", ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
}


internal extension CollectionViewFormSubtitleCell {
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            titleLabel.font    = .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote, compatibleWith: traitCollection)
            subtitleLabel.font = .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline, compatibleWith: traitCollection)
        } else {
            titleLabel.font    = .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote)
            subtitleLabel.font = .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline)
        }
    }
    
}

// MARK: - Cell Sizing
/// Cell sizing
extension CollectionViewFormSubtitleCell {
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:        The title text for the cell.
    ///   - subtitle:     The subtitle text for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image:        The leading image for the cell. The default is `nil`.
    ///   - emphasis:     The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont:    The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - subtitleFont: The subtitle font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineSubtitle: A boolean value indicating if the subtitle text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, subtitle: String?, compatibleWith traitCollection: UITraitCollection, image: UIImage? = nil,
                                        emphasis: Emphasis = .title, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineSubtitle: Bool = false) -> CGFloat {
        let titleTextFont:    UIFont
        let subtitleTextFont: UIFont
        
        if #available(iOS 10, *) {
            titleTextFont    = titleFont    ?? .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote, compatibleWith: traitCollection)
            subtitleTextFont = subtitleFont ?? .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline, compatibleWith: traitCollection)
        } else {
            titleTextFont    = titleFont    ?? .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote)
            subtitleTextFont = subtitleFont ?? .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline)
        }
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace) + 10.0
        }
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        let subtitleWidth = (subtitle as NSString?)?.boundingRect(with: .max, options: singleLineSubtitle ? [] : .usesLineFragmentOrigin,
                                                                  attributes: [NSFontAttributeName: subtitleTextFont],
                                                                  context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleWidth, subtitleWidth) + imageSpace
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:      The title text for the cell.
    ///   - subtitle:     The subtitle text for the cell.
    ///   - width:      The width constraint for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image:      The leading image for the cell. The default is `nil`.
    ///   - emphasis:   The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont:  The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - subtitleFont: The subtitle font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle: A boolean value indicating if the title text should be constrained to a single line. The default is `false`.
    ///   - singleLineSubtitle: A boolean value indicating if the subtitle text should be constrained to a single line. The default is `false`.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: String?, subtitle: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, emphasis: Emphasis = .title, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                         singleLineTitle: Bool = true, singleLineSubtitle: Bool = false) -> CGFloat {
        let titleTextFont:    UIFont
        let subtitleTextFont: UIFont
        
        if #available(iOS 10, *) {
            titleTextFont    = titleFont    ?? .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote, compatibleWith: traitCollection)
            subtitleTextFont = subtitleFont ?? .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline, compatibleWith: traitCollection)
        } else {
            titleTextFont    = titleFont    ?? .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote)
            subtitleTextFont = subtitleFont ?? .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline)
        }
        
        let imageSize = image?.size
        
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0.0 {
            displayScale = UIScreen.main.scale
        }
        
        let size = CGSize(width: imageSize == nil ? width : width - imageSize!.width - 10.0, height: CGFloat.greatestFiniteMagnitude)
        
        let titleHeight = (title as NSString?)?.boundingRect(with: size, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: titleTextFont],
                                                             context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        
        let subtitleHeight = (subtitle as NSString?)?.boundingRect(with: size, options: singleLineSubtitle ? [] : .usesLineFragmentOrigin,
                                                                   attributes: [NSFontAttributeName: subtitleTextFont],
                                                                   context: nil).height.ceiled(toScale: displayScale) ?? 0.0
        var combinedHeight = titleHeight + subtitleHeight
        if titleHeight !=~ 0.0 && subtitleHeight !=~ 0.0 {
            combinedHeight += CellTitleSubtitleSeparation
        }
        
        return max(combinedHeight, (imageSize?.height ?? 0.0))
    }
    
}

