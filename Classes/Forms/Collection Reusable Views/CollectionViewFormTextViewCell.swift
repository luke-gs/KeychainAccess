//
//  CollectionViewFormTextViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

open class CollectionViewFormTextViewCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    /// The title label for the cell.
    public let titleLabel = UILabel(frame: .zero)
    
    /// The text view for the cell.
    public let textView = FormTextView(frame: .zero, textContainer: nil)
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false && textView.isEditable { _ = textView.becomeFirstResponder() } }
    }
    
    
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
        selectionStyle = .underline
        
        let titleLabel       = self.titleLabel
        let textView         = self.textView
        
        titleLabel.adjustsFontForContentSizeCategory = true
        textView.adjustsFontForContentSizeCategory = true
        
        titleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        textView.font   = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        textView.placeholderLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        let contentView = self.contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        
        let placeholderLabel = textView.placeholderLabel
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
            placeholderLabel.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing(_:)), name: .UITextViewTextDidBeginEditing, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidEndEditing(_:)),   name: .UITextViewTextDidEndEditing,   object: textView)
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        
        let placeholderLabel = textView.placeholderLabel
        keyPathsAffectingLabelLayout.forEach {
            titleLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            placeholderLabel.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    
    // MARK: - Overrides
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentView = self.contentView
        let displayScale = traitCollection.currentDisplayScale
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        var contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        let accessorySize: CGSize
        if let size = self.accessoryView?.frame.size, size.isEmpty == false {
            accessorySize = size
            let inset = size.width + CollectionViewFormCell.accessoryContentInset
            contentRect.size.width -= inset
            
            if isRightToLeft {
                contentRect.origin.x += inset
            }
        } else {
            accessorySize = .zero
        }
        
        // We take 0.5 from the standard separation to deal with inconsistencies with how UITextView lays out text vs UILabel.
        // This does not affect the class sizing method.
        let interItemSpace = (CellTitleSubtitleSeparation - 0.5).ceiled(toScale: displayScale)
        
        let labelSize = titleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        let maximumTextViewHeight = contentRect.height - labelSize.height - interItemSpace
        let minimumTextViewHeight: CGFloat
        if let textViewFont = textView.font {
            minimumTextViewHeight = textViewFont.lineHeight + textViewFont.leading
        } else {
            minimumTextViewHeight = 18.0
        }
        
        let textViewSize = CGSize(width: (contentRect.width + 8.5).floored(toScale: displayScale), height: max(minimumTextViewHeight, min(maximumTextViewHeight, textView.contentSize.height)))
        
        let contentHeight = max(labelSize.height + textViewSize.height + interItemSpace, accessorySize.height)
        
        // Get content positions
        
        let contentYOrigin: CGFloat
        switch contentMode {
        case .top, .topLeft, .topRight:
            contentYOrigin = contentRect.minY
        case .bottom, .bottomLeft, .bottomRight:
            contentYOrigin = max(contentRect.minY, contentRect.maxY - contentHeight)
        default:
            contentYOrigin = max(contentRect.minY, contentRect.midY - contentHeight / 2.0)
        }
        
        accessoryView?.frame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.minX : contentRect.maxX - accessorySize.width, y: (contentYOrigin - (contentHeight - accessorySize.height) / 2.0).rounded(toScale: displayScale)), size: accessorySize)
        
        let titleFrame = CGRect(origin: CGPoint(x: isRightToLeft ? contentRect.maxX - labelSize.width : contentRect.minX, y: contentYOrigin), size: labelSize)
        titleLabel.frame = titleFrame
        textView.frame = CGRect(origin: CGPoint(x: contentRect.minX - 5.0, y: titleFrame.maxY + interItemSpace), size: textViewSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if keyPath == #keyPath(UITextView.contentOffset), let textView = object as? UITextView {
                // There are a few bugs in UITextView where, during resizing, the content offset gets set to a scrolled position valid
                // prior to the update, eg a user enters text, which causes resizing and a scroll simultaneously.
                // We guard against the case, and if any content offset change tries to occur when it's not valid,
                // we reset back to zero.
                if textView.contentOffset.y !=~ 0.0 && textView.contentSize.height <=~ textView.bounds.height {
                    textView.contentOffset.y = 0.0
                }
            } else {
                setNeedsLayout()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Accessibility

    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }
    
    open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            let text = textView.text
            if text?.isEmpty ?? true {
                return textView.placeholderLabel.text
            }
            return text
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    open override var isAccessibilityElement: Bool {
        get { return textView.isFirstResponder ? false : super.isAccessibilityElement }
        set { super.isAccessibilityElement = newValue }
    }
    
    
    // MARK: - Private methods
    
    @objc private func textViewDidBeginEditing(_ notification: NSNotification) {
        guard isSelected == false,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    @objc private func textViewDidEndEditing(_ notification: NSNotification) {
        guard isSelected,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for an instance of CollectionViewFormTextViewCell.
    /// You should use this method instead of creating a separate reference cell.
    ///
    /// - Parameters:
    ///   - title:      The title text for the cell.
    ///   - text:       The content text for the text view.
    ///   - width:      The content width for the cell.
    ///   - traitCollection: The trait collection context the cell will be presented in. This may affect the standard fonts.
    ///   - titleFont:  The title font of the cell. The default is `nil`, specifying the standard title font.
    ///   - textFont:   The content font for the text view. the default is `nil`, specifying the standard content font.
    /// - Returns:      The minimum appropriate height for the cell.
    open class func minimumContentHeight(withTitle title: String?, enteredText: String?, placeholder: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textViewFont: UIFont? = nil, placeholderFont: UIFont? = nil) -> CGFloat {
        var height: CGFloat = 0.0
        let screenScale = UIScreen.main.scale
        if let title = title {
            let titleTextFont = titleFont ?? UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            
            height += (title as NSString).boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleTextFont], context: nil).height.ceiled(toScale: screenScale)
            height += CellTitleSubtitleSeparation
        }
        
        let textFont = textViewFont ?? UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        
        height += max((enteredText as NSString?)?.boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil).height ?? 0.0, textFont.lineHeight).ceiled(toScale: screenScale)
        return height
    }
    
}
