//
//  CollectionViewFormSubtitleCell.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

private var textContext = 1

open class CollectionViewFormSubtitleCell: CollectionViewFormCell {
    
    /// The minimum content width for the cell, considering the text and detail text.
    ///
    /// - Parameters:
    ///   - text:             The text for the cell.
    ///   - detailText:       The detail text for the cell.
    ///   - singleLineDetail: A boolean value indicating whether the content should be forced to maintain a single line.
    /// - Returns:            The minimum content width for the cell.
    open class func minimumContentWidth(forText text: String, detailText: String?, singleLineDetail: Bool = false) -> CGFloat {
        let textWidth = (text as NSString).size(attributes: [NSFontAttributeName: fonts.0]).width        
        if let detailText = detailText {
            if singleLineDetail {
                let detailTextWidth = (detailText as NSString).size(attributes: [NSFontAttributeName: fonts.1]).width
                return ceil(max(textWidth, detailTextWidth))
            } else {
                return max(ceil(textWidth), 50.0)
            }
        }
        return ceil(textWidth)
    }
    
    
    /// The minimum content height for the cell, considering the text and detail text, in the specified content width.
    ///
    /// - Parameters:
    ///    - text:             The text for the cell.
    ///    - detailText:       The detail text for the cell.
    ///    - width:            The content width for the cell.
    ///    - singleLineDetail: A boolean value indicating whether the content should be forced to maintain a single line.
    /// - Returns:             The minimum content height for the cell.
    open class func minimumContentHeight(forText text: String, detailText: String, inWidth width: CGFloat, singleLineDetail: Bool = false) -> CGFloat {
        let textHeight = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: fonts.0], context: nil).height
        let detailTextHeight = (detailText as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: singleLineDetail ? [] : .usesLineFragmentOrigin, attributes: [NSFontAttributeName: fonts.1], context: nil).height
        let height = ceil(textHeight) + ceil(detailTextHeight) + 6.0
        return textHeight.isZero == false && detailTextHeight.isZero == false ? height + interLabelSeparation : height
    }
    
    public static let fonts = (UIFont.systemFont(ofSize: 14.5, weight: UIFontWeightSemibold), UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightSemibold))
    
    fileprivate static let interLabelSeparation: CGFloat = 2.0
    
    open let textLabel       = UILabel(frame: .zero)
    open let detailTextLabel = UILabel(frame: .zero)
    
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
    
    /// The content mode for the cell.
    /// This causes the cell to re-layout its content with the requested content parameters,
    /// in the vertical dimension.
    /// - note: Currently supports only .Top or .Center
    open override var contentMode: UIViewContentMode {
        didSet {
            if contentMode != oldValue { setNeedsLayout() }
        }
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
        textLabel.font       = CollectionViewFormSubtitleCell.fonts.0
        detailTextLabel.font = CollectionViewFormSubtitleCell.fonts.1
        
        let contentView = self.contentView
        contentView.addSubview(textLabel)
        contentView.addSubview(detailTextLabel)
        
        textLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [], context: &textContext)
        textLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), options: [], context: &textContext)
        textLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), options: [], context: &textContext)
        textLabel.addObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  options: [], context: &textContext)
        detailTextLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [], context: &textContext)
        detailTextLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), options: [], context: &textContext)
        detailTextLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), options: [], context: &textContext)
        detailTextLabel.addObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  options: [], context: &textContext)
    }
   
    deinit {
        textLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
        textLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &textContext)
        textLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
        textLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  context: &textContext)
        detailTextLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
        detailTextLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &textContext)
        detailTextLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
        detailTextLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  context: &textContext)
    }
    
    
    // MARK: - Layout
    
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
    
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
