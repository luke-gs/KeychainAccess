//
//  EntityCollectionViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

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
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        
        applyFonts()
    }
    
}

extension EntityCollectionViewCell {
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyFonts()
    }
    
    fileprivate func applyFonts() {
        let fontManager = FontManager.shared
        let traitCollection = self.traitCollection
        
        titleLabel.font    = fontManager.font(withStyle: .headline,  compatibleWith: traitCollection)
        subtitleLabel.font = fontManager.font(withStyle: .footnote1, compatibleWith: traitCollection)
        detailLabel.font   = fontManager.font(withStyle: .footnote2, compatibleWith: traitCollection)
        setNeedsLayout()
    }
    
}


extension EntityCollectionViewCell {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let scale = (window?.screen ?? .main).scale
        
        let contentView = self.contentView
        let contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        let titleHeight    = titleLabel.font.lineHeight.ceiled(toScale: scale)
        let subtitleHeight = subtitleLabel.font.lineHeight.ceiled(toScale: scale)
        let detailHeight   = detailLabel.font.lineHeight.ceiled(toScale: scale)
        
        let imageViewFrame: CGRect
        var textOrigin: CGPoint
        var textWidth: CGFloat
        
        switch style {
        case .hero:
            imageViewFrame  = CGRect(x: contentRect.midX - 92.0, y: contentRect.minY, width: 184.0, height: 160.0)
            textWidth = 182.0
            textOrigin = CGPoint(x: imageViewFrame.minX + 1, y: imageViewFrame.maxY + 9.0)
        case .detail:
            imageViewFrame  = CGRect(x: contentRect.minX, y: contentRect.midY - 48.0, width: 96.0, height: 96.0)
            let textHeight = titleHeight + subtitleHeight + detailHeight + 4.0
            textOrigin = CGPoint(x: imageViewFrame.maxX + 15.0, y: contentRect.midY - (textHeight / 2.0))
            textWidth = max(contentRect.width - 112.0, 0.0)
        }
        
        borderedImageView.frame = imageViewFrame
        
        titleLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: titleHeight))
        textOrigin.y += titleHeight + 2.0
        
        subtitleLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: subtitleHeight))
        textOrigin.y += subtitleHeight + 2.0
        
        detailLabel.frame = CGRect(origin: textOrigin, size: CGSize(width: textWidth, height: detailHeight))
        
        badgeView.sizeToFit()
        
        var badgeFrame = CGRect(origin: .zero, size: badgeView.sizeThatFits(.zero))
        let preferredBadgeCenter = CGPoint(x: imageViewFrame.maxX - 5.0, y: imageViewFrame.minY + 5.0)
        
        badgeFrame.origin.y = max(0.0, preferredBadgeCenter.y - (badgeFrame.height / 2.0))
        badgeFrame.origin.x = min(bounds.maxX, (preferredBadgeCenter.x + badgeFrame.width / 2.0)) - badgeFrame.width
        badgeView.frame = badgeFrame
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
        // TODO: Adjust sizing for trait collections.
        switch style {
        case .hero:     return 222.0
        case .detail:   return 96.0
        }
    }
    
}
