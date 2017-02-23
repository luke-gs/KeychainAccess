//
//  EntityCollectionViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var sourceLabelContext = 1


/// `EntityCollectionViewCell` is a cell for displaying MPOL entities with a standardized
/// MPOL branding and appearance.
///
/// `EntityCollectionViewCell supports displaying cells in two styles: "hero", and "detail".
/// The "hero" appearance focuses on the photo/placeholder icon, and shows detail text
/// labels below the context. The "detail" appearance shows the icon at the leading edge,
/// with detail trailing behind.
///
/// EntityCollectionViewCell manages updating its own fonts from its trait collection's
/// preferredContentSizeCategory. It is recommended you avoid updating them.
public class EntityCollectionViewCell: CollectionViewFormCell {
    
    
    /// The style types for an `EntityCollectionViewCell`. These include
    /// `.hero` and `.detail`.
    public enum Style: Int {
        /// The Hero style. This style emphasizes the icon.
        case hero
        
        /// The Detail style. This style emphasizes the icon and detail equally.
        case detail
    }
    
    
    /// The style for this cell. The default is `EntityCollectionViewCell.Style.hero`.
    public var style: Style = .hero {
        didSet {
            if style != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    
    /// The image view for the cell.
    public var imageView: UIImageView { return borderedImageView.imageView }
    
    
    /// The title label. This should be used for details such as the driver's name,
    /// vehicle's registration, etc.
    public let titleLabel = UILabel(frame: .zero)
    
    
    /// The subtitle label. This should be used for ancillery entity details.
    public let subtitleLabel = UILabel(frame: .zero)
    
    
    /// The detail label. This should be any secondary details.
    public let detailLabel = UILabel(frame: .zero)
    
    
    /// The source label.
    ///
    /// This label is positioned over the image view's bottom left corner, and
    /// indicates the data source the entity was fetched from.
    public let sourceLabel = SourceLabel(frame: .zero)
    
    
    /// The alert count for the entity.
    ///
    /// This configures a badge in the top left corner.
    /// The badge color will match the alertColor, or gray.
    public var alertCount: UInt = 0 {
        didSet {
            if alertCount == oldValue { return }
            
            badgeView.text = String(describing: alertCount)
            setNeedsLayout()
        }
    }
    
    
    /// The alert color for the entity.
    ///
    /// This color is used for the alert badge, and when non-`nil` applies a colored
    /// border around the image.
    public var alertColor: UIColor? {
        didSet {
            if alertColor == oldValue { return }
            
            badgeView.backgroundColor = alertColor ?? .gray
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
        badgeView.backgroundColor = .gray
        
        let contentView = self.contentView
        contentView.addSubview(detailLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(sourceLabel)
        
        sourceLabel.addObserver(self, forKeyPath: #keyPath(SourceLabel.text), options: [], context: &sourceLabelContext)
        
        applyFonts()
    }
    
    deinit {
        sourceLabel.removeObserver(self, forKeyPath: #keyPath(SourceLabel.text), context: &sourceLabelContext)
    }
    
}


// MARK: - Sizing class methods
/// Sizing class methods.
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
            let fontManager = FontManager.shared
            let scale = UIScreen.main.scale
            let heightOfFonts =  fontManager.font(withStyle: .headline,  compatibleWith: traitCollection).lineHeight.ceiled(toScale: scale) + fontManager.font(withStyle: .footnote1, compatibleWith: traitCollection).lineHeight.ceiled(toScale: scale) + fontManager.font(withStyle: .footnote2, compatibleWith: traitCollection).lineHeight.ceiled(toScale: scale)
            return 173.0 + heightOfFonts
        case .detail:
            return 96.0
        }
    }
    
}


// MARK: - Overrides
/// Overrides
extension EntityCollectionViewCell {
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyFonts()
    }
    
    public override func layoutSubviews() {
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
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sourceLabelContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}


// MARK: - Private methods
/// Private methods
fileprivate extension EntityCollectionViewCell {
    
    fileprivate func applyFonts() {
        let fontManager = FontManager.shared
        let traitCollection = self.traitCollection
        
        titleLabel.font    = fontManager.font(withStyle: .headline,  compatibleWith: traitCollection)
        subtitleLabel.font = fontManager.font(withStyle: .footnote1, compatibleWith: traitCollection)
        detailLabel.font   = fontManager.font(withStyle: .footnote2, compatibleWith: traitCollection)
        
        setNeedsLayout()
    }
    
}
