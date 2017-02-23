//
//  EntityCollectionViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var labelContentContext = 1

open class EntityCollectionViewCell: CollectionViewFormCell {
    
    public enum Style: Int {
        case hero, detail
    }
    
    public var style: Style = .hero {
        didSet {
            if style != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    public var imageView: UIImageView { return borderedImageView.imageView }
    
    public let titleLabel = UILabel(frame: .zero)
    
    public let subtitleLabel = UILabel(frame: .zero)
    
    public let detailLabel   = UILabel(frame: .zero)
    
    public let sourceLabel   = SourceLabel(frame: .zero)
    
    public var alertCount: UInt = 0 {
        didSet {
            if alertCount == oldValue { return }
            
            badgeView.text = String(describing: alertCount)
            setNeedsLayout()
        }
    }
    
    public var alertColor: UIColor? {
        didSet {
            if alertColor == oldValue { return }
            
            badgeView.backgroundColor = alertColor
            borderedImageView.borderColor = alertColor
        }
    }
    
    fileprivate let borderedImageView = BorderedImageView(frame: .zero)
    
    fileprivate let badgeView = BadgeView(frame: .zero)
    
    
    
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
        let contentView = self.contentView
        
        let traitCollection = self.traitCollection
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        
        let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.font = footnoteFont
        detailLabel.font   = footnoteFont
        
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory = true
        
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(sourceLabel)
        
        sourceLabel.addObserverForContentSizeKeys(self, context: &labelContentContext)
    }
    
    deinit {
        sourceLabel.removeObserverForContentSizeKeys(self, context: &labelContentContext)
    }
    
}


extension EntityCollectionViewCell {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let scale = (window?.screen ?? .main).scale
        
        let contentView = self.contentView
        let contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        let titleHeight:    CGFloat = titleLabel.text?.isEmpty    ?? true ? 0.0 : titleLabel.font.lineHeight.ceiled(toScale: scale)
        let subtitleHeight: CGFloat = subtitleLabel.text?.isEmpty ?? true ? 0.0 : subtitleLabel.font.lineHeight.ceiled(toScale: scale)
        let detailHeight:   CGFloat = detailLabel.text?.isEmpty   ?? true ? 0.0 : detailLabel.font.lineHeight.ceiled(toScale: scale)
        
        let imageViewFrame: CGRect
        var textOrigin:     CGPoint
        var textWidth:      CGFloat
        
        switch style {
        case .hero:
            imageViewFrame  = CGRect(x: (contentRect.midX - 92.0).rounded(toScale: scale), y: contentRect.minY, width: 184.0, height: 160.0)
            textOrigin = CGPoint(x: imageViewFrame.minX + 1, y: imageViewFrame.maxY + 9.0)
            textWidth  = contentRect.width - (textOrigin.x - contentRect.minX)
        case .detail:
            imageViewFrame  = CGRect(x: contentRect.minX.rounded(toScale: scale), y: (contentRect.midY - 48.0).rounded(toScale: scale), width: 96.0, height: 96.0)
            
            var textHeight: CGFloat = 0.0
            if titleHeight.isZero == false {
                textHeight += titleHeight
            }
            if subtitleHeight.isZero == false {
                if textHeight.isZero == false {
                    textHeight += 2.0
                }
                textHeight += subtitleHeight
            }
            if detailHeight.isZero == false {
                if textHeight.isZero == false {
                    textHeight += 2.0
                }
                textHeight += detailHeight
            }
            
            textOrigin = CGPoint(x: imageViewFrame.maxX + 15.0, y: (contentRect.midY - (textHeight / 2.0)).floored(toScale: scale))
            textWidth = max(contentRect.width - 112.0, 0.0)
        }
        
        borderedImageView.frame = imageViewFrame
        
        titleLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: titleHeight))
        textOrigin.y += titleHeight + 2.0
        
        subtitleLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: subtitleHeight))
        textOrigin.y += subtitleHeight.isZero ? 0.0 : subtitleHeight + 2.0
        
        detailLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: detailHeight))
        
        badgeView.sizeToFit()
        
        var badgeFrame = CGRect(origin: .zero, size: badgeView.sizeThatFits(.zero))
        let preferredBadgeCenter = CGPoint(x: imageViewFrame.maxX - 5.0, y: imageViewFrame.minY + 5.0)
        
        badgeFrame.origin.y = max(0.0, preferredBadgeCenter.y - (badgeFrame.height / 2.0))
        badgeFrame.origin.x = min(bounds.maxX, (preferredBadgeCenter.x + badgeFrame.width / 2.0)) - badgeFrame.width
        badgeView.frame = badgeFrame
        
        var sourceLabelSize = sourceLabel.sizeThatFits(.zero)
        sourceLabelSize.width = max(min(imageViewFrame.width - 16.0, sourceLabelSize.width), 0.0)
        sourceLabel.frame = CGRect(origin: CGPoint(x: imageViewFrame.minX + 8.0, y: imageViewFrame.maxY - 8.0 - sourceLabelSize.height),
                                   size: sourceLabelSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &labelContentContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}



extension EntityCollectionViewCell {
    
    public class func minimumContentWidth(forStyle style: Style) -> CGFloat {
        switch style {
        case .hero:     return 182.0
        case .detail:   return 250.0
        }
    }
    
    public class func minimumContentHeight(forStyle style: Style, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        switch style {
        case .hero:
            let scale = UIScreen.main.scale
            let heightOfFonts = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection).lineHeight.ceiled(toScale: scale) + (UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection).lineHeight.ceiled(toScale: scale) * 2.0)
            return 173.0 + heightOfFonts
        case .detail:
            return 96.0
        }
    }
    
}
