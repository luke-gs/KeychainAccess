//
//  CollectionViewFormSubtitleCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

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
    
    
    /// A boolean value indicating whether the cell represents an editable field.
    /// The default is `true`.
    ///
    /// This value can be used to inform MPOL apps that the cell should be
    /// displayed with the standard MPOL editable colors and/or adornments.
    ///
    /// This should be ignored by MPOL apps when the emphasis is on the title.
    public var isEditableField: Bool = true
    
    
    /// The emphasized element within the cell. The emphasized item will be highlighted
    ///  with stronger default fonts.
    ///
    /// Setting this property re-sets the label fonts to default
    open var emphasis: Emphasis = .title {
        didSet { if emphasis != oldValue { applyStandardFonts() } }
    }
    
    open var preferredLabelSeparation: CGFloat = CellTitleSubtitleSeparation {
        didSet {
            if (titleLabel.text?.isEmpty ?? true) == false && (subtitleLabel.text?.isEmpty ?? true) == false {
                titleSubtitleConstraint.constant = preferredLabelSeparation
            }
        }
    }
    
    
    // MARK: - Private/internal properties
    
    /// A boolean value indicating to MPOL applications that the cell represents an editable
    /// field. This variable is exposed via the additional MPOL property `isEditableField`,
    /// and should be ignored when the cell is "title-emphasised".
    ///
    /// The default is `true`.
    
    internal let textLayoutGuide = UILayoutGuide()
    
    private var titleSubtitleConstraint: NSLayoutConstraint!
    
    private var textLeadingConstraint: NSLayoutConstraint!
    
    
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
        
        imageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        
        subtitleLabel.numberOfLines = 0
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh + 1, for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh + 1, for: .horizontal)
        
        titleSubtitleConstraint  = NSLayoutConstraint(item: subtitleLabel,   attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        textLeadingConstraint    = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: imageView, attribute: .trailing)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom,   relatedBy: .equal,           toItem: textLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual,   toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading, priority: UILayoutPriorityDefaultHigh),
            textLeadingConstraint,
            titleSubtitleConstraint,
            
            NSLayoutConstraint(item: imageView,       attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultLow)
        ])
        
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.addObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.addObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
    }
   
    deinit {
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.removeObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.removeObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
                titleSubtitleConstraint.constant = (titleLabel.text?.isEmpty ?? true || subtitleLabel.text?.isEmpty ?? true) ? 0.0 : preferredLabelSeparation
            case let imageView as UIImageView:
                let noImage = imageView.image?.size.isEmpty ?? true
                imageView.isHidden = false
                textLeadingConstraint.constant = noImage ? 0.0 : 16.0
                updateLabelMaxSizes()
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            if bounds.width !=~ oldValue.width {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.width !=~ oldValue.width {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            let layoutMargins = self.layoutMargins
            if layoutMargins.left !=~ oldValue.left || layoutMargins.right !=~ oldValue.right {
                updateLabelMaxSizes()
            }
        }
    }
    
    open override var accessoryView: UIView? {
        didSet {
            updateLabelMaxSizes()
        }
    }
    
    open override var accessibilityLabel: String? {
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
    
    
    // MARK: - Private methods
    
    func updateLabelMaxSizes() {
        
        let width         = frame.width
        let layoutMargins = self.layoutMargins
        let accessoryViewWidth = accessoryView?.bounds.width ?? 0.0
        let imageViewWidth = imageView.image?.size.width ?? 0.0
        
        let allowedTextWidth = width - layoutMargins.left - layoutMargins.right - (accessoryViewWidth > 0.0 ? accessoryViewWidth + 10.0 : 0.0) - (imageViewWidth > 0.0 ? imageViewWidth + 16.0 : 0.0)
        
        titleLabel.preferredMaxLayoutWidth    = allowedTextWidth
        subtitleLabel.preferredMaxLayoutWidth = allowedTextWidth
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - image:              The leading image for the cell. The default is `nil`.
    ///   - emphasis:           The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - subtitleFont:       The subtitle font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `true`.
    ///   - singleLineSubtitle: A boolean value indicating if the subtitle text should be constrained to a single line. The default is `false`.
    ///   - accessoryViewWidth: The width for the accessory view.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(withTitle title: String?, subtitle: String?, compatibleWith traitCollection: UITraitCollection, image: UIImage? = nil,
                                        emphasis: Emphasis = .title, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil,
                                        singleLineTitle: Bool = true, singleLineSubtitle: Bool = false, accessoryViewWidth: CGFloat = 0.0) -> CGFloat {
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
            imageSpace = ceil(imageSpace) + 16.0
        }
        
        let displayScale = traitCollection.currentDisplayScale
        
        let titleWidth = (title as NSString?)?.boundingRect(with: .max, options: singleLineTitle ? [] : .usesLineFragmentOrigin,
                                                            attributes: [NSFontAttributeName: titleTextFont],
                                                            context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        let subtitleWidth = (subtitle as NSString?)?.boundingRect(with: .max, options: singleLineSubtitle ? [] : .usesLineFragmentOrigin,
                                                                  attributes: [NSFontAttributeName: subtitleTextFont],
                                                                  context: nil).width.ceiled(toScale: displayScale) ?? 0.0
        
        return max(titleWidth, subtitleWidth) + imageSpace + (accessoryViewWidth > 0.00001 ? accessoryViewWidth + 10.0 : 0.0)
    }
    
    
    /// Calculates the minimum content height for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - width:              The width constraint for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    ///   - image:              The leading image for the cell. The default is `nil`.
    ///   - emphasis:           The emphasis setting for the cell. The default is `.text`.
    ///   - titleFont:          The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - subtitleFont:       The subtitle font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineTitle:    A boolean value indicating if the title text should be constrained to a single line. The default is `false`.
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
        
        
        let displayScale = traitCollection.currentDisplayScale
        
        let size = CGSize(width: imageSize == nil ? width : width - imageSize!.width - 16.0, height: CGFloat.greatestFiniteMagnitude)
        
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

