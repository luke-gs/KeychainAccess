//
//  CollectionViewFormDetailCell.swift
//  Pods
//
//  Created by Rod Brown on 19/3/17.
//
//

import UIKit


fileprivate var kvoContext = 1


open class CollectionViewFormDetailCell: CollectionViewFormCell {
    
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    public let subtitleLabel: UILabel = UILabel(frame: .zero)

    
    public let detailLabel: UILabel = UILabel(frame: .zero)
    
    
    fileprivate var titleSubtitleSeparation: NSLayoutConstraint!
    
    fileprivate var subtitleDetailSeparation: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let titleLabel    = self.titleLabel
        let subtitleLabel = self.subtitleLabel
        let detailLabel   = self.detailLabel
        
        titleLabel.translatesAutoresizingMaskIntoConstraints    = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints   = false
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        detailLabel.isHidden   = true
        
        let contentView = self.contentView
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        
        let width: CGFloat = bounds.width
        titleLabel.preferredMaxLayoutWidth    = width
        subtitleLabel.preferredMaxLayoutWidth = width
        detailLabel.preferredMaxLayoutWidth   = width
        
        detailLabel.numberOfLines = 2
        
        titleSubtitleSeparation  = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,    attribute: .bottom)
        subtitleDetailSeparation = NSLayoutConstraint(item: detailLabel,   attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom)
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            titleSubtitleSeparation,
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            subtitleDetailSeparation,
            NSLayoutConstraint(item: detailLabel, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailLabel, attribute: .bottom,   relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .bottom),
        ])
        
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.addObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.addObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.addObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        detailLabel.addObserver(self,   forKeyPath: textKeyPath,     context: &kvoContext)
        detailLabel.addObserver(self,   forKeyPath: attrTextKeyPath, context: &kvoContext)
    }
    
    deinit {
        let textKeyPath     = #keyPath(UILabel.text)
        let attrTextKeyPath = #keyPath(UILabel.attributedText)
        titleLabel.removeObserver(self,    forKeyPath: textKeyPath,     context: &kvoContext)
        titleLabel.removeObserver(self,    forKeyPath: attrTextKeyPath, context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: textKeyPath,     context: &kvoContext)
        subtitleLabel.removeObserver(self, forKeyPath: attrTextKeyPath, context: &kvoContext)
        detailLabel.removeObserver(self,   forKeyPath: textKeyPath,     context: &kvoContext)
        detailLabel.removeObserver(self,   forKeyPath: attrTextKeyPath, context: &kvoContext)
    }
    
}


extension CollectionViewFormDetailCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
                
                let hasTitle    = (titleLabel.text?.isEmpty    ?? true) == false
                let hasSubtitle = (subtitleLabel.text?.isEmpty ?? true) == false
                let hasDetail   = (detailLabel.text?.isEmpty   ?? true) == false
                
                let titleSubtitleSeparationDistance = hasTitle && hasSubtitle ? CellTitleSubtitleSeparation : 0.0
                if titleSubtitleSeparationDistance !=~ titleSubtitleSeparation.constant {
                    titleSubtitleSeparation.constant = titleSubtitleSeparationDistance
                }
                
                let subtitleDetailSeparationDistance: CGFloat = (hasTitle || hasSubtitle) && hasDetail ? 7.0 : 0.0
                if subtitleDetailSeparationDistance !=~ subtitleDetailSeparation.constant {
                    subtitleDetailSeparation.constant = subtitleDetailSeparationDistance
                }
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            if width !=~ oldValue.width {
                // Make the text ensure it resizes to fit width on events where the width changes.
                titleLabel.preferredMaxLayoutWidth    = width
                subtitleLabel.preferredMaxLayoutWidth = width
                detailLabel.preferredMaxLayoutWidth   = width
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            let width = frame.width
            if width !=~ oldValue.width {
                // Make the text ensure it resizes to fit width on events where the width changes.
                titleLabel.preferredMaxLayoutWidth    = width
                subtitleLabel.preferredMaxLayoutWidth = width
                detailLabel.preferredMaxLayoutWidth   = width
            }
        }
    }
    
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            titleLabel.font    = .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote,    compatibleWith: traitCollection)
            detailLabel.font   = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            titleLabel.font    = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
            detailLabel.font   = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}
