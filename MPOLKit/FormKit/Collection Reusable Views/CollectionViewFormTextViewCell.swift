//
//  CollectionViewFormTextViewCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 11/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

private var titleContext        = 1
private var textViewFontContext = 2
private var textViewTextContext = 3

open class CollectionViewFormTextViewCell: CollectionViewFormCell {
    
    public static let fonts = (UIFont.systemFont(ofSize: 14.5, weight: UIFontWeightSemibold), UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightSemibold))
    
    fileprivate static let interLabelSeparation: CGFloat = 2.0
    
    
    /// Calculates the minimum content height for an instance of CollectionViewFormTextViewCell.
    /// You should use this method instead of creating a separate reference cell.
    ///
    /// - Parameters:
    ///   - title:       The title text for the cell.
    ///   - content:     The content to enter into the text view.
    ///   - width:       The content width for the cell.
    ///   - titleFont:   The title font of the cell. The default is the standard title font.
    ///   - contentFont: The content font for the text view. the default is the standard content font.
    /// - Returns:       The minimum appropriate height for the cell.
    open class func minimumContentHeight(withTitle title: String?, text: String?, inWidth width: CGFloat, titleFont: UIFont = fonts.0, textFont: UIFont = fonts.1) -> CGFloat {
        var height: CGFloat = 0.0
        let screenScale = UIScreen.main.scale
        if let title = title {
            height += (title as NSString).boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleFont], context: nil).height.ceiled(toScale: screenScale)
            height += interLabelSeparation
        }
        let detail = text ?? ""
        height += (detail as NSString).boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil).height.ceiled(toScale: screenScale)
        
        height += 6.0
        return height
    }
    
    
    /// The title label for the cell.
    open let titleLabel = UILabel(frame: .zero)
    
    /// The text view for the cell.
    open let textView = UITextView(frame: .zero, textContainer: nil)
    
    /// the placeholder label for the cell.
    open let placeholderLabel = UILabel(frame: .zero)
    
    /// The content mode for the cell.
    /// This causes the cell to re-layout its content with the requested content parameters,
    /// in the vertical dimension.
    ///
    /// - Note: Currently supports only .top or .center
    open override var contentMode: UIViewContentMode {
        didSet {
            if contentMode != oldValue { setNeedsLayout() }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel.font = CollectionViewFormTextViewCell.fonts.0
        
        textView.font = CollectionViewFormTextViewCell.fonts.1
        textView.textContainerInset = UIEdgeInsets(top: 0.0, left: -5.0, bottom: 0.0, right: -3.5)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = CollectionViewFormTextViewCell.fonts.1
        placeholderLabel.textColor = .gray
        placeholderLabel.backgroundColor = .clear
        
        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: textView, attribute: .leading),
            NSLayoutConstraint(item: placeholderLabel, attribute: .top, relatedBy: .equal, toItem: textView, attribute: .top),
            NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textView, attribute: .trailing),
            NSLayoutConstraint(item: placeholderLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: textView, attribute: .bottom)
        ])
        
        titleLabel.addObserverForContentSizeKeys(self, context: &titleContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.font), options: [], context: &textViewFontContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.text), options: [], context: &textViewTextContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange), name: .UITextViewTextDidChange, object: textView)
    }
    
    deinit {
        titleLabel.removeObserverForContentSizeKeys(self, context: &titleContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.font), context: &textViewFontContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.text), context: &textViewTextContext)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentBounds   = contentView.bounds
        let contentRect     = contentBounds.insetBy(contentView.layoutMargins)
        
        let titleSize       = titleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        let maxTextViewSize = titleSize.isEmpty ? contentRect.size : CGSize(width: contentRect.width, height: max(contentRect.size.height - titleSize.height - 9.0, 0.0))
        var textViewHeight  = textView.sizeThatFits(maxTextViewSize).height
        
        var currentYOffset: CGFloat
        if contentMode == .center {
            let heightForContent = titleSize.height + textViewHeight + (titleSize.height.isZero == false && textViewHeight.isZero == false ? CollectionViewFormTextViewCell.interLabelSeparation : 0.0)
            let availableContentHeight = contentRect.height
            currentYOffset = (contentRect.minY + max((availableContentHeight - heightForContent) / 2.0, 0.0)).rounded(toScale: window?.screen.scale ?? 1.0)
        } else {
            currentYOffset = contentRect.minY + 4.0
        }
        
        titleLabel.frame = CGRect(origin: CGPoint(x: contentRect.minX, y: currentYOffset), size: titleSize)
        currentYOffset += ceil(titleSize.height)
        if titleSize.height.isZero == false && textViewHeight.isZero == false { currentYOffset += CollectionViewFormTextViewCell.interLabelSeparation }
        
        textViewHeight = max(0.0, min(textViewHeight, contentBounds.height - currentYOffset))
        textView.frame = CGRect(x: contentRect.minX, y: currentYOffset, width: contentRect.width, height: textViewHeight)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &titleContext {
            setNeedsLayout()
        } else if context == &textViewFontContext {
            placeholderLabel.font = textView.font
        } else if context == &textViewTextContext {
            textViewTextDidChange()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

fileprivate extension CollectionViewFormTextViewCell {
    
    @objc fileprivate func textViewTextDidChange() {
        placeholderLabel.isHidden = (textView.text?.isEmpty ?? true) == false
    }
}
