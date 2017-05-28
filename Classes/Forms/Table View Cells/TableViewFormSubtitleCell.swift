//
//  TableViewFormSubtitleCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1


/// The `TableViewFormSubtitleCell` class implements a UITableViewCell subclass which provides
/// analogous content and behaviour to `CollectionViewFormSubtitleCell`, but for use with `UITableView`.
///
/// `TableViewFormSubtitleCell` adds to the behaviour of `UITableViewCellStyle.Subtitle` by providing support
/// for mutli-line labels in both the title and detail label. This can be important in implementing support
/// for content that must wrap and show in the detail, which the default cell does not support. Additionally
/// the class configures the labels with the appropriate fonts to replicate the appearance of
/// `CollectionViewFormSubtitleCell`.
///
/// Unlike it's Collection-based counterpart, `TableViewFormSubtitleCell` self-sizes with AutoLayout. Users
/// do not require to specify a default height, and can allow the cell to indicate it's height dynamically.
open class TableViewFormSubtitleCell: TableViewFormCell {
    
    public enum Emphasis {
        case title
        case subtitle
    }
    
    /// The text label for the cell. This is guaranteed to be non-nil.
    open override var textLabel: UILabel {
        return titleLabel
    }
    
    /// The detail text label for the cell. This is guaranteed to be non-nil.
    open override var detailTextLabel: UILabel {
        return subtitleLabel
    }
    
    open override var imageView: UIImageView {
        return _imageView
    }
    
    /// The font emphasis for the cell. The default is `.title`.
    open var emphasis: Emphasis = .title {
        didSet { applyStandardFonts() }
    }
    
    // MARK: - Private properties
    
    private let titleLabel = UILabel(frame: .zero)
    
    private let subtitleLabel = UILabel(frame: .zero)
    
    private let _imageView = UIImageView(frame: .zero)
    
    /// A boolean value indicating to MPOL applications that the cell represents an editable
    /// field. This variable is exposed via the additional MPOL property `isEditableField`,
    /// and should be ignored when the cell is "title-emphasised".
    ///
    /// The default is `true`.
    internal var mpol_isEditableField: Bool = true
    
    private let textLayoutGuide = UILayoutGuide()
    
    private var titleSubtitleConstraint: NSLayoutConstraint!
    
    private var textLeadingConstraint: NSLayoutConstraint!
    
    
    // MARK: - Initializers
    
    /// Initializes the cell with a reuse identifier.
    /// TableViewFormSubtitleCell does not utilize the `style` parameter, instead always using `.subtitle`.
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    /// TableViewFormSubtitleCell does not support NSCoding.
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
        imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        titleSubtitleConstraint = NSLayoutConstraint(item: subtitleLabel,   attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        textLeadingConstraint   = NSLayoutConstraint(item: textLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: imageView,  attribute: .trailing)
        
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
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual,   toItem: contentView, attribute: .trailingMargin),
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
        let textKeyPath = #keyPath(UILabel.text)
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
                titleSubtitleConstraint.constant = (titleLabel.text?.isEmpty ?? true || subtitleLabel.text?.isEmpty ?? true) ? 0.0 : CellTitleSubtitleSeparation
            case let imageView as UIImageView:
                let noImage = imageView.image?.size.isEmpty ?? true
                imageView.isHidden = noImage
                textLeadingConstraint.constant = noImage ? 0.0 : 10.0
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            textLabel.font       = .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote, compatibleWith: traitCollection)
            detailTextLabel.font = .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline, compatibleWith: traitCollection)
        } else {
            textLabel.font       = .preferredFont(forTextStyle: emphasis == .title ? .headline : .footnote)
            detailTextLabel.font = .preferredFont(forTextStyle: emphasis == .title ? .footnote : .headline)
        }
    }
    
}

