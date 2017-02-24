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
        case detail
    }
    
    fileprivate static let interLabelSeparation: CGFloat = 2.0
    
    open let textLabel       = UILabel(frame: .zero)
    open let detailTextLabel = UILabel(frame: .zero)
    
    public private(set) lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: .zero)
        self.contentView.addSubview(imageView)
        self.hasImageView = true
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), options: [], context: &contentContext)
        return imageView
    }()
    
    open var emphasis: Emphasis = .title {
        didSet { applyStandardFonts() }
    }
    
    open var accessoryView: UIView? {
        didSet {
            if accessoryView == oldValue { return }
            
            oldValue?.removeFromSuperview()
            if let newAccessoryView = accessoryView {
                contentView.addSubview(newAccessoryView)
            }
            setNeedsLayout()
        }
    }
    
    fileprivate var hasImageView: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    /// The content mode for the cell.
    /// This causes the cell to re-layout its content with the requested content parameters,
    /// in the vertical dimension.
    /// - note: Currently supports only .Top or .Center
    open override var contentMode: UIViewContentMode {
        didSet { if contentMode != oldValue { setNeedsLayout() } }
    }
    
    
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
        let contentView = self.contentView
        
        applyStandardFonts()
        
        contentView.addSubview(textLabel)
        contentView.addSubview(detailTextLabel)
        
        textLabel.addObserverForContentSizeKeys(self, context: &contentContext)
        detailTextLabel.removeObserverForContentSizeKeys(self, context: &contentContext)
    }
   
    deinit {
        textLabel.removeObserverForContentSizeKeys(self, context: &contentContext)
        detailTextLabel.removeObserverForContentSizeKeys(self, context: &contentContext)
        
        if hasImageView {
            imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
        }
    }
    
}


extension CollectionViewFormSubtitleCell {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let contentView = self.contentView
        
        let contentBounds    = contentView.bounds
        let contentInsets    = contentView.layoutMargins
        
        var availableWidth  = contentBounds.width - contentInsets.left - contentInsets.right
        
        if let accessoryView = self.accessoryView {
            // TODO: Adjust accessory view to observe content mode
            
            let width = accessoryView.bounds.width
            accessoryView.center = CGPoint(x: contentBounds.width - contentInsets.right - (width / 2.0), y: (contentBounds.size.height / 2.0).rounded(toScale: UIScreen.main.scale))
            availableWidth -= width + 10.0
        }
        
        let textLabelSize       = textLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        var detailTextLabelSize = detailTextLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        detailTextLabelSize.width = min(detailTextLabelSize.width, availableWidth + contentInsets.right)
        
        var currentYOffset: CGFloat
        
        if contentMode == .center {
            let heightForContent = textLabelSize.height + detailTextLabelSize.height + (textLabelSize.height.isZero == false && detailTextLabelSize.height.isZero == false ? CollectionViewFormSubtitleCell.interLabelSeparation : 0.0)
            let availableContentHeight = contentBounds.height - contentInsets.top - contentInsets.bottom
            currentYOffset = (contentInsets.top + max((availableContentHeight - heightForContent) / 2.0, 0.0)).rounded(toScale: window?.screen.scale ?? 1.0)
        } else {
            currentYOffset = contentInsets.top + 3.0
        }
        
        textLabel.frame = CGRect(origin: CGPoint(x: contentInsets.left, y: currentYOffset), size: textLabelSize)
        currentYOffset += ceil(textLabelSize.height)
        if textLabelSize.height.isZero == false && detailTextLabelSize.height.isZero == false { currentYOffset += 2.0 }
        
        detailTextLabelSize.height = max(0.0, min(detailTextLabelSize.height, contentBounds.height - currentYOffset))
        detailTextLabel.frame = CGRect(origin: CGPoint(x: contentInsets.left, y: currentYOffset), size: detailTextLabelSize)
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        applyStandardFonts()
    }
    
}


internal extension CollectionViewFormSubtitleCell {
    
    internal class func font(withEmphasis emphasis: Bool, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        return .preferredFont(forTextStyle: emphasis ? .headline : .footnote, compatibleWith: traitCollection)
    }
    
}

fileprivate extension CollectionViewFormSubtitleCell {
    
    fileprivate func applyStandardFonts() {
        let traitCollection = self.traitCollection
        textLabel.font       = CollectionViewFormSubtitleCell.font(withEmphasis: emphasis == .title,  compatibleWith: traitCollection)
        detailTextLabel.font = CollectionViewFormSubtitleCell.font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        textLabel.adjustsFontForContentSizeCategory = true
        detailTextLabel.adjustsFontForContentSizeCategory = true
    }
    
}


// MARK: - Cell Sizing
/// Cell sizing
extension CollectionViewFormSubtitleCell {
    
    
    /// Calculates the minimum content width for a cell, considering the text and font details.
    ///
    /// - Parameters:
    ///   - text: The text for the cell.
    ///   - detailText: The detail text for the cell.
    ///   - traitCollection: The trait collection the cell will be deisplayed in.
    ///   - image: The leading image for the cell. The default is `nil`.
    ///   - emphasis: The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont: The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content width for the cell.
    open class func minimumContentWidth(forText text: String, detailText: String?, compatibleWith traitCollection: UITraitCollection, image: UIImage? = nil,
                                        emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil, singleLineDetail: Bool = false) -> CGFloat {
        let textFont = titleFont ?? font(withEmphasis: emphasis == .title, compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        var imageSpace = image?.size.width ?? 0.0
        if imageSpace > 0.0 {
            imageSpace = ceil(imageSpace)
            imageSpace += 10.0
        }
        
        let textWidth = (text as NSString).size(attributes: [NSFontAttributeName: textFont]).width
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
    ///   - emphasis: The emphasis setting for the cell. The default is `.title`.
    ///   - titleFont: The title font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - detailFont: The detail font. The default is `nil`, indicating the calculation should use the default for the emphasis mode.
    ///   - singleLineDetail: A boolean value indicating if the detail text should be constrained to a single line. The default is `false`.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(forText text: String, detailText: String, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection,
                                         image: UIImage? = nil, emphasis: Emphasis = .title, titleFont: UIFont? = nil, detailFont: UIFont? = nil, singleLineDetail: Bool = false) -> CGFloat {
        let textFont       = titleFont  ?? font(withEmphasis: emphasis == .title,  compatibleWith: traitCollection)
        let detailTextFont = detailFont ?? font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        let textHeight = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil).height
        let detailTextHeight = (detailText as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: singleLineDetail ? [] : .usesLineFragmentOrigin, attributes: [NSFontAttributeName: detailTextFont], context: nil).height
        let height = ceil(textHeight) + ceil(detailTextHeight) + 6.0
        return textHeight.isZero == false && detailTextHeight.isZero == false ? height + interLabelSeparation : height
    }
    
}








